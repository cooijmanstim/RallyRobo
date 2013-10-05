function [board] = board_create_example()
global RR;
board = zeros(12, 12, RR.nfeatures);

for o = {RR.features.repair         [2 1; 2 5; 5 3; 9 3; 5 8; 1 10]
         RR.features.conveyor_north [repmat(3, [3 1]) (1:3)';
                                     repmat(7, [2 1]) (4:5)']
         RR.features.conveyor_east  [(3:6)'  repmat(4, [4 1]);
                                     (7:12)' repmat(6, [6 1])]
         RR.features.conveyor_west  [(1:4)'  repmat(6, [4, 1]);
                                     (5:12)' repmat(7, [8, 1])]
         RR.features.conveyor_south [4 7]
         RR.features.conveyor_turning_counterclockwise [7 4; 4 7]
         RR.features.conveyor_turning_clockwise [7 6; 3 4; 4 6]
         RR.features.pit            [8 5; 9 5; 3 7; 6 10]
         RR.features.wall_east      [4 5]
         RR.features.wall_north     [10 2; 4 5; 7 7; 3 10]
         RR.features.wall_west      [4 1; 10 2; 7 3; 1 5; 11 9; 5 12]
         RR.features.wall_south     [6 1]}'
    feature = o{1}; xs = o{2};
    for i = 1:size(xs, 1)
        board = board_enable_feature(board, xs(i, :), feature);
    end
end
