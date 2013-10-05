function [game] = game_create_example()
game = game_create(12, 12, 4, 4);
game.board = board_create_example();
game.state.checkpoints = [1,12;9,8;8,2;5,9];
game.state.robots.position = [1,3;11,4;1,8;9,11];
game.state.robots.direction = [0,1;-1,0;-1,0;1,0];
