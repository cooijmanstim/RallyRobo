function [dir] = generate_directions()
dir.byname.east  = 0;
dir.byname.north = 1;
dir.byname.west  = 2;
dir.byname.south = 3;
dir.asnumbers = [0 1 2 3];
dir.asrows = [ 0  1; 1  0; 0 -1; -1  0];
