function [x] = image_blur_slightly(x)
n = 5;
sigma = exprnd(3);
h = fspecial('gaussian', n, sigma);
x = imfilter(x, h);
