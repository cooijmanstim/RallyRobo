function [p] = board_has_feature(board, x, feature)
p = squeeze(board(x(1), x(2), feature));