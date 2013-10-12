function [x] = image_distort_slightly(x)
    x = image_transform_slightly(x);
    x = image_blotch_slightly(x);
    x = image_noise_slightly(x);
