init();
close();
global BoardFigure;
game = game_create_random(12, 12, 2, 4);

drawBoard(game.board,game.state.robots);