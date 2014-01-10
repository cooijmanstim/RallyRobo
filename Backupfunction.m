function [game] = Backupfunction( DataStructure, PlayersPos )
global RR;
featuresets = {};
featuresets{5} = RR.features.pit;
featuresets{6} = RR.features.wall_west;
featuresets{7} = RR.features.wall_east;
featuresets{8} = RR.features.wall_north;
featuresets{9} = RR.features.wall_south;
featuresets{10} = [RR.features.wall_east RR.features.wall_north];
featuresets{11} = [RR.features.wall_east RR.features.wall_south];
featuresets{12} = [RR.features.wall_west RR.features.wall_north];
featuresets{13} = [RR.features.wall_west RR.features.wall_south];
featuresets{14} = RR.features.conveyor_west;
featuresets{15} = RR.features.conveyor_east;
featuresets{16} = RR.features.conveyor_south;
featuresets{17} = RR.features.conveyor_north;
featuresets{18} = [RR.features.conveyor_east RR.features.conveyor_turning_clockwise];
featuresets{19} = [RR.features.conveyor_south RR.features.conveyor_turning_clockwise];
featuresets{20} = [RR.features.conveyor_west RR.features.conveyor_turning_clockwise];
featuresets{21} = [RR.features.conveyor_north RR.features.conveyor_turning_clockwise];
featuresets{22} = [RR.features.conveyor_south RR.features.conveyor_turning_counterclockwise];
featuresets{23} = [RR.features.conveyor_east RR.features.conveyor_turning_counterclockwise];
featuresets{24} = [RR.features.conveyor_north RR.features.conveyor_turning_counterclockwise];
featuresets{25} = [RR.features.conveyor_west RR.features.conveyor_turning_counterclockwise];
featuresets{26} = RR.features.repair;

width = size(DataStructure,2);
height = size(DataStructure,1);

game = game_create(height, width);

% since the checkpoints are not encountered in order, we can't directly add
% them to the game. order them in this temporary cell array first.
checkpoints = {};

for i=1:height
    for j=1:width
        x = DataStructure(height-i+1,j);
        nobjects = ceil((1 + floor(log10(abs(x)))) / 2);
        for k = 1:nobjects
            if((1 + floor(log10(abs(x)))) > 2)
                y=rem(x,100);
                x=floor(x/100);
            else
                y = x;
            end
            
            if y < 5
                checkpoints{y} = [i j];
            else
                game.board = board_enable_feature(game.board, [i j], featuresets{y});
            end
        end                    
    end
end

for checkpoint = checkpoints
    game = game_add_checkpoint(game, cell2mat(checkpoint));
end

for s=1:length(PlayersPos)
    x = PlayersPos(s);
    %n is the number of digits in x
    n = (1 + floor(log10(abs(x))));
    direction = floor(x/10^(n-1)) - 1;
    r = rem(x,10^(n-1));
    i = ceil(r/width);
    j = r-(floor(r/width)*width);
    if(j==0)
        j = width;
    end
    
    % flip vertical axis
    i = height - i + 1;
    
    game = game_add_robot(game, robot_create(s, [i j], direction));
end

end
