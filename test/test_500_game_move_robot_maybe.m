function [success] = test_500_game_move_robot_maybe()
global RR;

game = game_create_example();
irobot = 3;
game.state.robots.position(irobot, :) = [5 4];

moves = {'north' false % wall inside
         'east'  false % wall inside
         'south' true
         'east'  true
         'north' true
         'west'  false % wall outside
         'north' true
         'west'  true
         'south' false % wall outside
         'north' true
         'west'  true  % into pit
         'east'  false
         'north' false
         'west'  false
         'south' false};

for i = 1:size(moves, 1)
    dx = RR.directions.byname.(moves{i, 1});
    [game, moved] = game_move_robot_maybe(game, irobot, dx);
    if moved ~= moves{i, 2}
        success = false;
        return;
    end
end

success = true;
