function [net, info] = cnn_cifar_100(varargin)
% CNN_CIFAR   Demonstrates MatConvNet on CIFAR-10
%    The demo includes two standard model: LeNet and Network in
%    Network (NIN). Use the 'modelType' option to choose one.

opts.modelType = 'lenet';
[opts, varargin] = vl_argparse(opts, varargin);

% this can be dagnn as well
opts.networkType = 'dagnn';
opts.labelType = 'fine';

data_root = '/home/arash/Software/Repositories/neurobit/data/dl/cifar/cifar-100/';
opts.expDir = fullfile(data_root, sprintf('cifar-100-%s-%s-%s', opts.modelType, opts.networkType, opts.labelType));
[opts, varargin] = vl_argparse(opts, varargin);

opts.dataDir = fullfile(data_root, 'cifar');
opts.imdbPath = fullfile(data_root, 'cifar-100-matlab', 'imdb-cifar-100.mat');
opts.whitenData = true;
opts.contrastNormalization = true;

opts.train.gpus = 1;
opts = vl_argparse(opts, varargin);
if ~isfield(opts.train, 'gpus'), opts.train.gpus = []; end;

% -------------------------------------------------------------------------
%                                                    Prepare model and data
% -------------------------------------------------------------------------

switch opts.modelType
  case 'lenet'
    net = cnn_cifar_100_init('networkType', opts.networkType);
  case 'nin'
    net = cnn_cifar_100_init_nin('networkType', opts.networkType);
  otherwise
    error('Unknown model type ''%s''.', opts.modelType);
end

if exist(opts.imdbPath, 'file')
  imdb = load(opts.imdbPath);
else
  imdb = getCifarImdb(opts);
  mkdir(opts.expDir);
  save(opts.imdbPath, '-struct', 'imdb');
end

net.meta.classes.name = imdb.meta.classes(:)';

% -------------------------------------------------------------------------
%                                                                     Train
% -------------------------------------------------------------------------

switch opts.networkType
  case 'simplenn', trainfn = @cnn_train;
  case 'dagnn', trainfn = @cnn_train_dag;
end

[net, info] = trainfn(net, imdb, getBatch(opts), ...
  'expDir', opts.expDir, ...
  net.meta.trainOpts, ...
  opts.train, ...
  'val', find(imdb.images.set == 3));

% -------------------------------------------------------------------------
function fn = getBatch(opts)
% -------------------------------------------------------------------------
switch lower(opts.networkType)
  case 'simplenn'
    fn = @(x,y) getSimpleNNBatch(x,y);
  case 'dagnn'
    bopts = struct('numGpus', numel(opts.train.gpus));
    fn = @(x,y) getDagNNBatch(bopts,x,y);
end

% -------------------------------------------------------------------------
function [images, labels] = getSimpleNNBatch(imdb, batch)
% -------------------------------------------------------------------------
images = imdb.images.data(:,:,:,batch);
labels = imdb.images.labels(1,batch);
if rand > 0.5, images=fliplr(images); end

% -------------------------------------------------------------------------
function inputs = getDagNNBatch(opts, imdb, batch)
% -------------------------------------------------------------------------
images = imdb.images.data(:,:,:,batch);
labels = imdb.images.labels(1,batch);
if rand > 0.5, images=fliplr(images); end
if opts.numGpus > 0
  images = gpuArray(images);
end
inputs = {'input', images, 'label', labels};

% -------------------------------------------------------------------------
function imdb = getCifarImdb(opts)
% -------------------------------------------------------------------------
% Preapre the imdb structure, returns image data with mean image subtracted
unpackPath = fullfile(opts.dataDir, 'cifar-100-matlab');
files = {'train.mat', 'test.mat'};
files = cellfun(@(fn) fullfile(unpackPath, fn), files, 'UniformOutput', false);
file_set = uint8([1, 3]);

if any(cellfun(@(fn) ~exist(fn, 'file'), files))
  url = 'http://www.cs.toronto.edu/~kriz/cifar-100-matlab.tar.gz';
  fprintf('downloading %s\n', url);
  untar(url, opts.dataDir);
end

labelType = [opts.labelType, '_labels'];

data = cell(1, numel(files));
labels = cell(1, numel(files));
sets = cell(1, numel(files));
for fi = 1:numel(files)
  fd = load(files{fi});
  data{fi} = permute(reshape(fd.data',32,32,3,[]),[2 1 3 4]);
  labels{fi} = fd.(labelType)' + 1; % Index from 1
  sets{fi} = repmat(file_set(fi), size(labels{fi}));
end

set = cat(2, sets{:});
data = single(cat(4, data{:}));

% remove mean in any case
dataMean = mean(data(:,:,:,set == 1), 4);
data = bsxfun(@minus, data, dataMean);

% normalize by image mean and std as suggested in `An Analysis of
% Single-Layer Networks in Unsupervised Feature Learning` Adam
% Coates, Honglak Lee, Andrew Y. Ng

if opts.contrastNormalization
  z = reshape(data,[],60000);
  z = bsxfun(@minus, z, mean(z,1));
  n = std(z,0,1);
  z = bsxfun(@times, z, mean(n) ./ max(n, 40));
  data = reshape(z, 32, 32, 3, []);
end

if opts.whitenData
  z = reshape(data,[],60000);
  W = z(:,set == 1)*z(:,set == 1)'/60000;
  [V,D] = eig(W);
  % the scale is selected to approximately preserve the norm of W
  d2 = diag(D);
  en = sqrt(mean(d2));
  z = V*diag(en./max(sqrt(d2), 10))*V'*z;
  data = reshape(z, 32, 32, 3, []);
end

clNames = load(fullfile(unpackPath, 'meta.mat'));
label_names = [opts.labelType, '_label_names'];

imdb.images.data = data;
imdb.images.labels = single(cat(2, labels{:}));
imdb.images.set = set;
imdb.meta.sets = {'train', 'val', 'test'};
imdb.meta.classes = clNames.(label_names);
