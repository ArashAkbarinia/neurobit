close all;

Macbeth = zeros(4,6,3); 
Macbeth(:,:,1) = [115, 196,  93,  90, 130,  99; 220,  72, 195,  91, 160, 229;  43,  71, 176, 238, 188,   0; 245, 200, 160, 120, 83, 50];
Macbeth(:,:,2) = [ 81, 149, 123, 108, 129, 191; 123,  92,  84,  59, 189, 161;  62, 149,  48, 200,  84, 136; 245, 201, 161, 121, 84, 50];
Macbeth(:,:,3) = [ 67, 129, 157,  65, 176, 171;  45, 168,  98, 105,  62,  41; 147,  72,  56,  22, 150, 166; 240, 201, 161, 121, 85, 50];
mypic = Macbeth;
%mypic = double(imread('D:\Aesthetics\small_macbeth.jpg'));
%mypic = double(imread('D:\Aesthetics\macbeth.jpg'));
%mypic = double(imread('D:\Aesthetics\test1.jpg'));
%mypic = double(imread('D:\Aesthetics\test2.jpg'));
%mypic = double(imread('D:\Aesthetics\20macbethDC.jpg'));
%mypic_XYZ = sRGB2XYZ(mypic, true, false, [10^4 10^4 10^4]); %gammacorrect = true, max pix value > 1, max luminance = daylight
%mypic_lsY = XYZ2lsY(mypic_XYZ);
%alej_image(mypic); figure(gcf)



lsY = XYZ2lsY(sRGB2XYZ(mypic, true, false, [10^2 10^2 10^2]),'evenly_ditributed_stds');
[n,m,p] = size(lsY);    
if p==3
    lsY = reshape(lsY,n*m,p);
    mycolor = reshape(mypic,n*m,p)./255;
end
 fit2014_all_nojunk('br'); hold on;

scatter3(lsY(:,1), lsY(:,2), lsY(:,3), 10, mycolor,'filled','Marker','o', 'SizeData',100); hold off;
xlabel('l'); 
ylabel('s');
zlabel('Y');
view(2); axis square;

uiopen('D:\MATLAB\huemaps\Macbeth.fig',1)



