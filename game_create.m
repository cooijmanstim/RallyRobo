function [game] = game_create(m, n, nrobots, ncheckpoints)
global RR;

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
% robots.position(i, :) similarly
game.state.robots.position = zeros(nrobots, 2);
% robots.direction(i, :) is the direction the ith robot is facing,
% represented by a displacement vector
game.state.robots.direction = repmat(RR.directions.byname.east, [nrobots 1]);
% progress(i) is the number of the checkpoint the ith robot is chasing
game.state.progress = ones(nrobots, 1);
