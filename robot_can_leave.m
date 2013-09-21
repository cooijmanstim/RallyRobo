function [p] = robot_can_leave(game, irobot, x, dx)
global RR;
p = any(game.board(x(1), x(2), RR.obstructions.leave(dx)));
