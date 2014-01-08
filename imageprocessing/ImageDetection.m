clear;close all ;

%read in the picture of the board
[im,map] = imread('example.bmp');

%convert the image to a grayscale
im = rgbtograyscale(im);

%scale the grayscale image to a binary image using a threshold depending on
%the pictures contrast (Higher contrast uses higher threshold
threshold = 12; 
im = relativeScaling(im,threshold);


%remove the noise / GOD function
im = bwareaopen(im, 30);

%look for corners in the binary picture
corners = corner(im,300);

%look for external corners in the list of corners obtained
external_corner = ExternalCorners(corners);

%Determine the angle of rotation needed, based on 2 of the outer corners
alpha = calculate_angle(external_corner);

%rotate the image using the angle 
rotated_board = imrotate(im,(alpha));

%look for corners in the rotated image
newcorners = corner(rotated_board,300);

%look for external corners in the straightened image
outer = OuterCorners(newcorners);

%construct a grid of corners based on the outer corners of the straightened
%image
tiles = getTiles(outer,12);

%display the image, and plot the grid of corners on it
figure, imshow(rotated_board);
hold on
plot(tiles(:,3), tiles(:,4), 'r*');
plot(tiles(:,5), tiles(:,6), 'b*');
plot(tiles(:,7), tiles(:,8), 'y*');
plot(tiles(:,9), tiles(:,10), 'g*');