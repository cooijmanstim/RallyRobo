function [p] = robot_can_enter(game, irobot, x, dx)
global RR;
p = any(game.board(x(1), x(2), RR.obstructions.enter(dx)));
