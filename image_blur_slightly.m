function [x] = image_blur_slightly(x)
n = 5;
sigma = exprnd(2);
h = fspecial('gaussian', n, sigma);
x = imfilter(x, h);
