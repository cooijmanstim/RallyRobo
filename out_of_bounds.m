function [p] = out_of_bounds(board, x)
p = any(1 > [x 1] | [x 1] > size(board));
