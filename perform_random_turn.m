% testing the java interface

clear; clc;
init();
game = RallyRobo.Game.example_game();
RallyRobo.Card.fill_empty_registers_randomly(game);
initBoardFigure(game);
refreshBoard(game);
keyboard;
game.perform_turn();
refreshBoard(game);

for i = 1:game.robots.size()
    game.robots.get(i-1).registers
    game.robots.get(i-1).damage
end
