clear all

I = imread('IMG_0376.tif');
figure(1); imshow(I); title('Original image');

p=1;
n=0;
sig=1;

Lgw = general_cc(I,n,p,sig);

Igw = rgbscaling(I,Lgw,ones(3,1)/3);

figure(2); imshow(Igw); title('Greyworld Estimate');
