function [success] = test_200_robot_can_leave()
global RR;

game = game_create_example();

% the red robot
irobot = 3;
x = game.state.robots.position(irobot, :);
% should be able to leave in any direction
dxs = RR.directions.asrows;

for i = 1:RR.ndirections;
    if ~robot_can_leave(game, irobot, x, dxs(i, :))
        success = false;
        return;
    end
end

success = true;
