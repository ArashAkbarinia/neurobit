function info = cifar_100_test(varargin)

% experiment and data paths
% opts.expDir = 'data/fcn32s-voc11';
opts.expDir = '/home/arash/Software/Repositories/neurobit/data/dl/cifar/cifar-100/results';
% opts.dataDir = 'data/voc11';
opts.dataDir = '/home/arash/Software/Repositories/neurobit/data/dl/cifar/cifar-100/cifar-100-lenet-dagnn-fine';
opts.modelPath = '/home/arash/Software/Repositories/neurobit/data/dl/cifar/cifar-100/cifar-100-lenet-dagnn-fine/net-epoch-45.mat';
opts.modelFamily = 'matconvnet';
[opts, varargin] = vl_argparse(opts, varargin);

% experiment setup
% opts.imdbPath = fullfile(opts.expDir, 'imdb.mat');
opts.imdbPath = '/home/arash/Software/Repositories/neurobit/data/dl/cifar/cifar-100/cifar-100-matlab/imdb-cifar-100.mat';
opts.vocEdition = '11';
opts.vocAdditionalSegmentations = true;
opts.vocAdditionalSegmentationsMergeMode = 2;
opts.gpus = 1;
opts = vl_argparse(opts, varargin);

resPath = fullfile(opts.expDir, 'results-cifar-100-lenet-dagnn-fine.mat');

if ~isempty(opts.gpus)
  gpuDevice(opts.gpus(1))
end

% -------------------------------------------------------------------------
% Setup data
% -------------------------------------------------------------------------

% Get PASCAL VOC 11/12 segmentation dataset plus Berkeley's additional
% segmentations
if exist(opts.imdbPath)
  imdb = load(opts.imdbPath);
else
  imdb = vocSetup('dataDir', opts.dataDir, ...
    'edition', opts.vocEdition, ...
    'includeTest', false, ...
    'includeSegmentation', true, ...
    'includeDetection', false);
  if opts.vocAdditionalSegmentations
    imdb = vocSetupAdditionalSegmentations(...
      imdb, ...
      'dataDir', opts.dataDir, ...
      'mergeMode', opts.vocAdditionalSegmentationsMergeMode);
  end
  mkdir(opts.expDir);
  save(opts.imdbPath, '-struct', 'imdb');
end

% Get validation subset
% val = find(imdb.images.set == 2 & imdb.images.segmentation);
val = find(imdb.images.set == 3);

% -------------------------------------------------------------------------
% Setup model
% -------------------------------------------------------------------------

switch opts.modelFamily
  case 'matconvnet'
    net = load(opts.modelPath);
    net = dagnn.DagNN.loadobj(net.net);
    net.mode = 'test';
    %     for name = {'objective', 'accuracy'}
    %       net.removeLayer(name);
    %     end
    %     net.meta.normalization.averageImage = reshape(net.meta.normalization.rgbMean,1,1,3);
    predVar = net.getVarIndex('prediction');
    %     predVar = net.getVarIndex('prob');
    inputVar = 'input';
    imageNeedsToBeMultiple = true;
    
  case 'ModelZoo'
    net = dagnn.DagNN.loadobj(load(opts.modelPath));
    net.mode = 'test';
    predVar = net.getVarIndex('upscore');
    inputVar = 'data';
    imageNeedsToBeMultiple = false;
    
  case 'TVG'
    net = dagnn.DagNN.loadobj(load(opts.modelPath));
    net.mode = 'test';
    predVar = net.getVarIndex('coarse');
    inputVar = 'data';
    imageNeedsToBeMultiple = false;
end

if ~isempty(opts.gpus)
  gpuDevice(opts.gpus(1));
  net.move('gpu');
end
net.mode = 'test';

results = zeros(1, numel(val));
for i = 1:numel(val)
  %   imId = val(i);
  %   name = imdb.images.name{imId};
  %   rgbPath = sprintf(imdb.paths.image, name);
  %   labelsPath = sprintf(imdb.paths.classSegmentation, name);
  
  % Load an image and gt segmentation
  %   rgb = vl_imreadjpeg({rgbPath});
  rgb = imdb.images.data(:, :, :, i);
  %   rgb = rgb{1};
  %   anno = imread(labelsPath);
  %   lb = single(anno);
  %   lb = mod(lb + 1, 256); % 0 = ignore, 1 = bkg
  
  % Subtract the mean (color)
  im = single(rgb);
  %   im = bsxfun(@minus, single(rgb), net.meta.normalization.averageImage);
  
  % Soome networks requires the image to be a multiple of 32 pixels
  if imageNeedsToBeMultiple
    sz = [size(im,1), size(im,2)];
    sz_ = round(sz / 32)*32;
    im_ = imresize(im, sz_);
  else
    im_ = im;
  end
  
  if ~isempty(opts.gpus)
    im_ = gpuArray(im_);
  end
  
  net.eval({inputVar, im_});
  scores_ = gather(net.vars(predVar).value);
  [~,pred_] = max(scores_,[],3);
  
  if imageNeedsToBeMultiple
    pred = imresize(pred_, sz, 'method', 'nearest');
  else
    pred = pred_;
  end
  
  
  results(i) = imdb.images.labels(i) == pred_;
  % Plots
  if false%mod(i - 1,30) == 0 || i == numel(val)
    
    % Print segmentation
    figure(i);clf;
    imshow(uint8(rgb));
    title(['GT: ' imdb.meta.classes{imdb.images.labels(i)}, ' | RS: ', imdb.meta.classes{pred_}]);
    drawnow;
  end
end

% save results
save(resPath, 'results');
disp(['Accuracy: ', num2str(sum(results) / numel(results))]);

end
