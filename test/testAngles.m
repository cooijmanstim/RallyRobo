
 dir.byname.east  = [ 0  1];
    dir.byname.north = [ 1  0];
    dir.byname.west  = [ 0 -1];
    dir.byname.south = [-1  0];
    dir.asrows = [dir.byname.east
                  dir.byname.north
                  dir.byname.west
                  dir.byname.south];
              
              
    tic
    
for c = 1: 1000000
    z =  logical(dir.asrows(randi(size( dir.asrows, 1), 1, 1), :));
    ang = angle(z);
end
toc