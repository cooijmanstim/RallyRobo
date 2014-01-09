function [game] = game_create_random(m, n, nrobots, ncheckpoints)
global RR;

game = game_create(m, n);
game.board = board_create_random(m, n);

% assume square so both coordinates can have the same distribution
assert(m == n);

for i = 1:ncheckpoints
    game = game_add_checkpoint(game, game_randx(game));
end

for i = 1:nrobots
    game = game_add_robot(game, robot_create(i, game_randx(game), randi(RR.ndirections)));
end
