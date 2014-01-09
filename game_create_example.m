function [game] = game_create_example()
game = game_create(0, 0);
game.board = board_create_example();
for x = [12 1; 8 9; 2 8; 9 5]'
    game = game_add_checkpoint(game, x');
end

xs = [3 1; 4 11; 8 1; 11 9];
dirs = [0 3 3 1];
for i = 1:length(dirs)
    game = game_add_robot(game, robot_create(i, xs(i, :), dirs(i)));
end
