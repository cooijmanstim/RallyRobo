function [x] = image_noise_slightly(x)
x = imnoise(x, 'poisson');
