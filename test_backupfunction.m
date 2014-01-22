clear; clc; close all;
init();
ds = [1     0     0     0     6     0    26     0     0     0     0     0 
     0     0     0     0     0     0     0     0     0     0    26     0  
    26     0     8     0     0     5     0     0     0     0     0     0  
     0     0     0     0     4     0     0     0     0     0     6     0  
     0     0     0     0    26     0     0     0     2     0     0     0  
     0     0     5    22    14    14   814    14    14    14    14    14  
    14    14    14    20     0     0    18    15    15    15    15    15  
     6    26     0    10     0     0    17     5     5     0     0     0  
     0     0    18    15    15    15    24     0     0     0     0     0  
     0     0    17     0    26     0     6     0    26     0     0     0  
     0     0    17     0     0     0     0     3     0    12     0     0  
     0    26    17     6     0     9     0     0     0     0     0     0];
ps = [ 249         421        -2107        1109];
[m, n] = size(ds);
game = RallyRobo.Game(m, n);
for i = 1:4
    game.board.add_checkpoint([0 0]);
    game.add_robot([1 1], RallyRobo.Direction.East);
end
mc_backupfunction(game, ds, ps);
[ds2,ps2] = mc_backupfunction_inverse(game);
game2 = RallyRobo.Game(m, n);
for i = 1:4
    game2.board.add_checkpoint([0 0]);
    game2.add_robot([1 1], RallyRobo.Direction.East);
end
mc_backupfunction(game2, ds2,ps2);
assert(game.equals(game2));

% this might fail because there are multiple equivalent representations
assert(all(ds(:) == ds2(:)));
assert(all(ps(:) == ps2(:)));

initBoardFigure(game);
refreshBoard(game);
