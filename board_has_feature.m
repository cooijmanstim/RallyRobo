function [p] = board_has_feature(board, x, feature)
global RR;
if out_of_bounds(board, x);
    p = RR.borderfeatureset(feature);
else
    p = squeeze(board(x(1), x(2), feature));
end
