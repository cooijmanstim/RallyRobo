function [tiles, featuresets, gamestates] = generate_training_images(n)
[tiles, featuresets, gamestates] = generate_tile_images(n, @postprocessfn);

function [x] = postprocessfn(x)
% there's no use in thresholding and making the image logical because
% matlab stores logical quantities in byte-sized chunks -.-
x = rgb2gray(x);
