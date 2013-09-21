clear; clc;

init();
close();
global BoardFigure;
game = game_create_random(12, 12, 2, 4);
%game = game_create_example();


initBoardFigure(game);

refreshBoard(game.board,game.state.robots, game.state.checkpoints);