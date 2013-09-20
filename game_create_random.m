function [game] = game_create_random(m, n, nrobots, ncheckpoints)
global RR;

game = game_create(m, n, nrobots, ncheckpoints);
game.board = board_create_random(m, n);

% assume square so both coordinates can have the same distribution
assert(m == n);

game.state.checkpoints = randi(m, ncheckpoints, 2);

% ensure no two robots end up on the same tile
assert(m * n >= nrobots);
game.state.robots.position = randi(m, nrobots, 2);
while has_duplicate_rows(game.state.robots)
    game.state.robots.position = randi(m, nrobots, 2);
end

game.state.robots.direction = RR.directions.asrows(randi(RR.ndirections, nrobots, 1), :);
