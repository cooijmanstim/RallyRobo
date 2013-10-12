function [x] = image_transform_slightly(x)
px = [0 0
      0 size(x, 2)
      size(x, 1) 0
      size(x, 1) size(x, 2)];
py = px + normrnd(0, 2, size(px));
T = cp2tform(px, py, 'projective');
x = imtransform(x, T);
