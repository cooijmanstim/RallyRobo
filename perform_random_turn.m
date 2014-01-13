% testing the java interface

clear classes;
init();
game = RallyRobo.Game.example_game();
RallyRobo.Card.fill_empty_registers_randomly(game);
initBoardFigure(game);
refreshBoard(game);
keyboard;
game.perform_turn();
refreshBoard(game);
