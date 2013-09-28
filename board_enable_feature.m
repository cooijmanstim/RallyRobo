function [board] = board_enable_feature(board, x, feature)
board(x(1), x(2), feature) = 1;
