function [x] = image_blotch_slightly(x)
assert(isinteger(x));

center = arrayfun(@(n) randi(n, 1), size(x));
S = diag(1./(size(x).^2));

blotch = zeros(size(x));
for i = 1:size(x, 1)
    for j = 1:size(x, 2)
        for k = 1:size(x, 3)
            v = [i j k] - center;
            blotch(i, j, k) = v*S*v';
        end
    end
end

blotch = uint8(blotch/max(blotch(:)) * 255);

sign = randi(1, 1)*2 - 1;
x = x + sign*blotch;
x = max(0, min(255, x));
