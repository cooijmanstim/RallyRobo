function [x] = image_blotch_slightly(x)
if isinteger(x)
    x = double(x)/255;
end
center = arrayfun(@(n) randi(n, 1), size(x));
[xs ys zs] = ndgrid(1:size(x, 1), 1:size(x, 2), 1:size(x, 3));
S = diag(1./size(x)); % why no color imbalance?
f = @(x) x*S*x';
blotch = arrayfun(@(x, y, z) f([x y z] - center), xs, ys, zs);
blotch = blotch/max(blotch(:));

sign = randi(1, 1)*2 - 1;
x = x + sign*blotch;
x = max(0, min(1, x));
