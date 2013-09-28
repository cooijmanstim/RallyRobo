function [board] = board_create_example()
global RR;
board = zeros(12, 12, RR.nfeatures);

for o = {RR.features.repair         [2 1; 2 5; 5 3; 9 3; 5 8; 1 10]
         RR.features.conveyor_north [3 1; 3 2; 3 3; 7 4; 7 5]
         RR.features.conveyor_east  [3 4; 4 4; 5 4; 6 4; 7 6; 8 6; 9 6; 10 6; 11 6; 12 6]
         RR.features.conveyor_turning_clockwise [7 6; 3 4]
         RR.features.conveyor_turning_counterclockwise [7 4]
         RR.features.pit            [8 5; 9 5; 3 7; 6 10]
         RR.features.wall_east      [4 5]
         RR.features.wall_north     [10 2; 4 5; 7 7; 3 10]
         RR.features.wall_west      [4 1; 10 2; 7 3; 1 7; 11 9; 5 12]
         RR.features.wall_south     [6 1]}'
    feature = o{1}; xys = o{2};
    for i = 1:size(xys, 1)
        board(xys(i, 1), xys(i, 2), feature) = 1;
    end
end
