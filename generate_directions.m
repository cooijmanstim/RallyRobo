function [dir] = generate_directions()
    % TODO: figure out a better way to store these
    dir.byname.east  = [ 0  1];
    dir.byname.north = [ 1  0];
    dir.byname.west  = [ 0 -1];
    dir.byname.south = [-1  0];
    dir.asrows = [dir.byname.east
                  dir.byname.north
                  dir.byname.west
                  dir.byname.south];
