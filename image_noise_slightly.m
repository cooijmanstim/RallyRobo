function [x] = image_noise_slightly(x)
if isinteger(x)
    x = double(x)/255;
end
x = x + normrnd(0, 1e-1, size(x));
x = max(0, min(1, x));
