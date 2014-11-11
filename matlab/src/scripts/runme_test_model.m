clearvars;
close all;
clc;

Macbeth = zeros(4,6,3); 
Macbeth(:,:,1) = [115, 196,  93,  90, 130,  99; 220,  72, 195,  91, 160, 229;  43,  71, 176, 238, 188,   0; 245, 200, 160, 120, 83, 50];
Macbeth(:,:,2) = [ 81, 149, 123, 108, 129, 191; 123,  92,  84,  59, 189, 161;  62, 149,  48, 200,  84, 136; 245, 201, 161, 121, 84, 50];
Macbeth(:,:,3) = [ 67, 129, 157,  65, 176, 171;  45, 168,  98, 105,  62,  41; 147,  72,  56,  22, 150, 166; 240, 201, 161, 121, 85, 50];

PngScale = 100;
MacbethPng1 = kron(Macbeth(:, :, 1), ones(1, PngScale));
MacbethPng(:, :, 1) = kron(MacbethPng1, ones(PngScale, 1));
MacbethPng2 = kron(Macbeth(:, :, 2), ones(1, PngScale));
MacbethPng(:, :, 2) = kron(MacbethPng2, ones(PngScale, 1));
MacbethPng3 = kron(Macbeth(:, :, 3), ones(1, PngScale));
MacbethPng(:, :, 3) = kron(MacbethPng3, ones(PngScale, 1));

% FIXME: when it's changed to im2double doesn't work as expected
mypic = double(imread('colorapp_pep.png'));

%mypic = Macbeth(1,1:2,:);
%mypic = double(imread('D:\Aesthetics\small_macbeth.jpg'));
%mypic = double(imread('D:\Aesthetics\test1.jpg'));
%mypic = double(imread('D:\Aesthetics\test2.jpg'));
%mypic = double(imread('D:\Aesthetics\20macbethDC.jpg'));
%mypic_XYZ = sRGB2XYZ(mypic, true, false, [10^4 10^4 10^4]); %gammacorrect = true, max pix value > 1, max luminance = daylight
%mypic_lsY = XYZ2lsY(mypic_XYZ);
%alej_image(mypic); figure(gcf)
[G, B, Pp, Pk, R, O, Y, Br, Gr, Ach] = sRGB2Focals(mypic);


h =figure;
subplot(3,4,1);
alej_image(mypic,[],[],0);axis('normal'); title('original');
subplot(3,4,2); 
alej_image(G,1,0,1);colormap(gray); axis('normal'); title('green');
subplot(3,4,3);
alej_image(B,1,0,1);colormap(gray); axis('normal'); title('blue');
subplot(3,4,4);
alej_image(Pp,1,0,1);colormap(gray); axis('normal'); title('purple');
subplot(3,4,5);
alej_image(Pk,1,0,1);colormap(gray); axis('normal'); title('pink');
subplot(3,4,6);
alej_image(R,1,0,1);colormap(gray); axis('normal'); title('red');
subplot(3,4,7);
alej_image(O,1,0,1);colormap(gray); axis('normal'); title('orange');
subplot(3,4,8);
alej_image(Y,1,0,1);colormap(gray); axis('normal'); title('yellow');
subplot(3,4,9);
alej_image(Br,1,0,1);colormap(gray); axis('normal'); title('brown');
subplot(3,4,10);
alej_image(Gr,1,0,1);colormap(gray); axis('normal'); title('grey');
subplot(3,4,11);
alej_image(Ach,1,0,0);colormap(gray); axis('normal'); title('Luminance');

% saveas(h,'D:\MATLAB\huemaps\Macbeth.fig','fig');

% figure;
% fit2014_all_large('a'); hold on;
% lsY = XYZ2lsY(sRGB2XYZ(mypic, true, false, [10^2 10^2 10^2]),'evenly_ditributed_stds');
% [n,m,p] = size(lsY);    
% if p==3
%     lsY = reshape(lsY,n*m,p);
% end
% plot3(lsY(:,1), lsY(:,2), lsY(:,3), '.r'); hold off;
