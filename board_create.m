function [board] = board_create(m, n)
% board(i, j, k) is one if the kth feature (see tfi) is present in the tile
% at (i, j)
global RR;
board = false(m, n, RR.nfeatures);
