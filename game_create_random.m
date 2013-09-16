function [game] = game_create_random(m, n, nrobots, ncheckpoints)
global RR;

game = game_create(m, n, nrobots, ncheckpoints);
game.board = board_create_random(m, n);

% assume square so both coordinates can have the same distribution
assert(m == n);

game.state.checkpoints = randi(m, ncheckpoints, 2);

% ensure no two robots end up on the same tile
assert(m * n >= nrobots);
while has_duplicate_rows(game.state.robots)
    game.state.robots = randi(m, nrobots, 2);
end

game.state.directions = randi(RR.ndirections, nrobots, 1) - 1;
