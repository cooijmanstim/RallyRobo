clear; clc; close all;
%% Initiation Game structure
init();

% The sample board to draw  ( numbers as in the specifications )
ds = [1     0     0     0     6     0    26     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0    26     0
    26     0     8     0     0     5     0     0     0     0     0     0
     0     0     0     0     4     0     0     0     0     0     6     0
     0     0     0     0    26     0     0     0     2     0     0     0
     0     0     5    1222    14    14   1114    14    14    14    14    14
    14    14    14    20     0     0    18    15    15    15    15    15
     6    26     0    10     0     0    17     5     5     0     0     0
     0     0    18    15    15    15    24     0     0     0     0     0
     0     0    17     0    26     0     6     0    26     0     0     0
     0     0    17     0     0     0     0     3     0    12     0     0
     0    26    17     6     0     9     0     0     0     0     0     0];
ps = [ 249         421        2107        1109];
game = Backupfunction(ds, ps);
initBoardFigure(game);
refreshBoard(game);
