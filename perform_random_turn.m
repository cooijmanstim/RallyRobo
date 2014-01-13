% testing the java interface

clear classes;
init();
game = game_create_example();
jgame = game_to_java(game);
RallyRobo.Card.fill_empty_registers_randomly(jgame);
jgame.perform_turn();
game2 = game_from_java(jgame);
