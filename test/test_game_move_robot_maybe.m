function [success] = test_game_move_robot_maybe()
global RR;

game = game_create_example();

irobot = 3;
dxs = [RR.directions.byname.south
       RR.directions.byname.west   % into wall; should fail
       RR.directions.byname.east
       RR.directions.byname.east
       RR.directions.byname.east]; % out of pit; should fail
moveds = [true false true true false];

for i = 1:length(moveds)
    [game, moved] = game_move_robot_maybe(game, irobot, dxs(i, :));
    if moved ~= moveds(i)
        success = false;
        return;
    end
end
