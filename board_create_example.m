function [board] = board_create_example()
% board(i, j, k) is one if the kth feature (see tfi) is present in the tile
% at (i, j)
global RR;
board = zeros(12, 12, RR.nfeatures);

% repair statons
board(2,1,2) = 1;
board(2,5,2) = 1;
board(5,3,2) = 1;
board(9,3,2) = 1;
board(5,8,2) = 1;
board(1,10,2) = 1;

% conveyor belt
board(3,1,8) = 1;
board(3,2,8) = 1;
board(3,3,8) = 1;
board(3,4,7) = 1;
board(3,4,11) = 1;
board(4,4,7) = 1;
board(5,4,7) = 1;
board(6,4,7) = 1;
board(7,4,8) = 1;
board(7,4,12) = 1;
board(7,5,8) = 1;
board(7,6,7) = 1;
board(7,6,11) = 1;
board(8,6,7) = 1;
board(9,6,7) = 1;
board(10,6,7) = 1;
board(11,6,7) = 1;
board(12,6,7) = 1;

% pits

board(8,5,1) = 1;
board(9,5,1) = 1;
board(3,7,1) = 1;
board(6,10,1) = 1;

% walls

% east
board(4,5,3) = 1;

%north
board(10,2,4) = 1;
board(4,5,4) = 1;
board(7,7,4) = 1;
board(3,10,4) = 1;

%west
board(4,1,5) = 1;
board(10,2,5) = 1;
board(7,3,5) = 1;
board(1,7,5) = 1;
board(11,9,5) = 1;
board(5,12,5) = 1;

%south
board(6,1,6) = 1;