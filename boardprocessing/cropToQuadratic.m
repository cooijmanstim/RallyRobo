function [ im_out ] = cropToQuadratic( im )

width = size(im,2);
height = size(im,1);
minim = min([width,height]);

im_out = imcrop(im,[(width-minim)/2+1 (height-minim)/2+1 minim minim]);


end