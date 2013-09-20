function [game, moved] = game_move_robot_maybe(game, irobot, dx)
% move robot, pushing others if they are in the way
% does not move (and returns moved=false) if the move is obstructed or
% would involving pushing a robot through an obstruction.
%
% NOTE: according to the rules, others do not get pushed if movement is
% due to conveyor belt action, so do not use this function for that

% assume going east
xold = game.robots.position(irobot, :);
xnew = xold + dx;

% TODO: what if moving outside the boundaries of the board? maybe grow the
% board to 14x14 with a border of pits to avoid this case

if any(game.board(xold(1), xold(2), get_obstructions_to_leaving(dx)) ...
    || game.board(xnew(1), xnew(2), get_obstructions_to_entering(dx)))
    moved = false;
    return;
end

% which robots are at xnew?
irobot2 = find(all(bsxfun(@eq, game.robots.position, xnew), 2), 1);
% assume that at most one robot is there (otherwise we have a bug)
assert(length(irobot2 < 2));
% if there is a robot there
if ~empty(irobot2)
    % maybe move it recursively.  this means the pushed robot may push
    % another robot.
    [game, moved] = game_move_robot_maybe(game, irobot2, dx);
    if ~moved
        return;
    end
end

game.robots.position(irobot, :) = xnew;
