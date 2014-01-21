function [cards, DataStructure, PlayersPos] = the_one_function(...
    color, hand, last_checkpoints, locked_registers, ...
    DataStructure, PlayersPos)
assert(nargin >= 4);

height = 12; width = 12;
ncheckpoints = 4; nrobots = length(last_checkpoints);
game = RallyRobo.Game(height, width);
for i = 1:ncheckpoints
    game.board.add_checkpoint([0 0]);
end
for i = 1:nrobots
    game.add_robot([1 1], RallyRobo.Direction.East);
end

if isempty(DataStructure)
    % TODO: image processing function
    % TODO: how does the image get passed in?
    ImageDetection?(game, ???);
else
    Backupfunction(game, DataStructure, PlayersPos);
end

assert(length(last_checkpoints) == nrobots);
for i = 1:nrobots
    game.robots.get(i-1).next_checkpoint = last_checkpoints(i)+1;
end

assert(size(locked_registers, 1) == nrobots);
assert(size(locked_registers, 2) == 6);
for i = 1:nrobots
    robot = game.robots.get(i-1);
    robot.registers = locked_registers(i, 1:5);
    robot.damage = 9 - locked_registers(i, 6);
end

% TODO: figure out robot number from color
irobot = some_function_of(color);
strategy = RallyRobo.Strategy.MonteCarloHeuristicSmart;
cards = strategy.decide(game, irobot-1, hand);
