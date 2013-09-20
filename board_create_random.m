function [board] = board_create_random(m, n)
% board(i, j, k) is one if the kth feature (see tfi) is present in the tile
% at (i, j)
global RR;
% probability of each feature appearing; somewhat arbitrary
P = repmat(shiftdim([4 5 10 10 10 10 3 3 3 3 1 1]/144, -1), [m n 1]);
board = binornd(1, P, [m n RR.nfeatures]);
