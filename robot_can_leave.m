function [p] = robot_can_leave(game, irobot, x, dx)
global RR;
p = ~any(board_has_feature(game.board, x, RR.obstructions.leave(dx)));
