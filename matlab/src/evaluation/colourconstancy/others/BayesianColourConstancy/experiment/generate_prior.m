function [mu,Cov]  = generate_prior(outside,wbsetting,ridge,dataset,dims,ind)

if ~exist('ridge','var')
    ridge = 0;
end
if ~exist('wbsetting','var')
    wbsetting = 'autowb';
end
if ~exist('dataset','var')
    dataset = 'ccdatabase';
end
if ~exist('dims','var')
    dims = 2;
end

PLOT = 0;

switch dataset
 case 'ccdatabase'
  outdoor =load_outdoor_label;
  rg = load_groundtruth_illuminants('rg',wbsetting);
  if dims == 3
      rg(:,3) = 1-sum(rg,2);
  end
  if exist('ind','var')
      outdoor = outdoor(ind);
      rg = rg(ind,:);
  end
  
 case 'greyball'
  cd ~/colorconstancy/experiments/sfu/
  [mu,Cov] = fit_prior_gauss(outside,ridge,'greyball',dims);
  cd ~/colorconstancy/experiments/ccdatabase;
  Cov = Cov + ridge*diag(diag(Cov));
  return;
end

  
switch outside
 case -1
 case 0
  rg = rg(outdoor==0,:);
 case 1
  rg = rg(outdoor==1,:);
end

try
    [ignore,g] = train(gauss,data(rg));
    mu = g.mean;
    Cov = g.cov + ridge*diag(diag(g.cov));
catch
    addpath ~/matlab/toolboxes/spider/
    use_spider
    [ignore,g] = train(gauss,data(rg));
    mu = g.mean;
    Cov = g.cov + ridge * diag(diag(g.cov));
end

if PLOT
    g.cov = Cov;
    
    figure(1); clf;
    subplot(121)

    scatter(rg(:,1),rg(:,2))
    axis equal square;
    axis([0 1 0 1]);
    subplot(122)

    [X,Y] = meshgrid(0:.025:1,0:.025:1);
    gr = [X(:),Y(:)];
    
    p = test(g,data(gr));
    
    surf(X,Y,reshape(p.X,size(X,1),size(X,2)))
end