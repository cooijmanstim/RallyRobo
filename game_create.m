function [game] = game_create(m, n, nrobots, ncheckpoints)
game = [];
game.height = m;
game.width = n;
game.nrobots = nrobots;
game.ncheckpoints = ncheckpoints;

game.board = board_create(m, n);

% isolate the stuff that changes as the game progresses
game.state = [];

% checkpoints(i, :) is a 2-element vector [y x] containing the row-major
% coordinates of the ith checkpoint
game.state.checkpoints = zeros(ncheckpoints, 2);
% robots(i, :) similarly
game.state.robots.position = zeros(nrobots, 2);
% directions(i) is the direction the ith robot is facing, represented by an
% integer [1 2 3 4] for [east north west south]
game.state.robots.direction = zeros(nrobots, 2);
% progress(i) is the number of the checkpoint the ith robot is chasing
game.state.progress = ones(nrobots, 1);
