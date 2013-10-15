function [xs, ys] = training_images_to_matrix(xs, ys)
% creates training matrix for a single label
% (e.g. xs = tiles; ys = featuresets(:, RR.features.pit);)
% xs can be huge so avoid copying

% ys is mx1, xs is mxn, each row of xs contains images with the same y.  so
% replicate ys horizontally to match their sizes.
ys = repmat(ys, [1 size(xs, 2)]);

% turn images into column vectors
xs = cellfun(@(x) x(:), xs, 'UniformOutput', false);

% now turn both into matrices with m*n rows
xs = [xs{:}]';
ys = ys(:);
