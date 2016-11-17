function plot_cropped_image(I,crop,range)
if isempty(I), I=0; end
[a,b]=size(I);
if nargin<2 || isempty(crop), crop=0; end
if nargin<3
  imagesc(I(crop+1:a-crop,crop+1:b-crop,:));
else
  imagesc(I(crop+1:a-crop,crop+1:b-crop,:),range);
end
axis('equal','tight'), set(gca,'XTick',[],'YTick',[],'FontSize',11);
drawnow

cmap=colormap('gray');cmap=1-cmap;colormap(cmap);
