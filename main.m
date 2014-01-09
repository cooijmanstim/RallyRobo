clear; clc;

init();
close();
global BoardFigure;
game = game_create_example();
initBoardFigure(game);
refreshBoard(game.board, game.robots, game.checkpoints);