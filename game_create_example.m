function [game] = game_create_example()
game = [];
game.nrobots = 4;
game.ncheckpoints = 4;

game.board = board_create_example();

game.height = board_height(game.board);
game.width = board_width(game.board);

% isolate the stuff that changes as the game progresses
game.state = [];

% checkpoints(i, :) is a 2-element vector [y x] containing the row-major
% coordinates of the ith checkpoint
game.state.checkpoints = [1,12;9,8;8,2;5,9];

% robots(i, :) similarly
game.state.robots.position = [1,2;11,4;1,8;9,11];
% directions(i) is the direction the ith robot is facing, represented by an
% coordinate [1,0;0,1;-1,0;0,-1] for [east;north;west;south]
game.state.robots.direction = [0,1;1,0;1,0;1,0];
% progress(i) is the number of the checkpoint the ith robot is chasing
game.state.progress = ones(4, 1);
