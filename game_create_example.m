function [game] = game_create_example()
game = game_create(12, 12, 4, 4);
game.board = board_create_example();
game.state.checkpoints = [12 1; 8 9; 2 8; 9 5];
game.state.robots.position = [3 1; 4 11; 8 1; 11 9];
game.state.robots.direction = [0 1; -1 0; -1 0; 1 0];
