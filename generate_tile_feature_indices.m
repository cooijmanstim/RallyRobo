function [tfi] = generate_tile_feature_indices()
    tfi = [];
    tfi.pit = 1;
    tfi.repair = 2;
    tfi.wall_east = 3;
    tfi.wall_north = 4;
    tfi.wall_west = 5;
    tfi.wall_south = 6;
    tfi.conveyor_east = 7;
    tfi.conveyor_north = 8;
    tfi.conveyor_west = 9;
    tfi.conveyor_south = 10;
    tfi.conveyor_turning_clockwise = 11;
    tfi.conveyor_turning_counterclockwise = 12;
end
