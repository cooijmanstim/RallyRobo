function [game] = Backupfunction( DataStructure, PlayersPos )
featuresets = backupfunction_featuresets();

width = size(DataStructure,2);
height = size(DataStructure,1);

game = RallyRobo.Game(height, width);

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
                for h = 1:length(featuresets{y})
                    feature = featuresets{y}(h);
                    game.board.set_feature([i j], feature);
                end
            end
        end                    
    end
end

for checkpoint = checkpoints
    game.board.add_checkpoint(cell2mat(checkpoint));
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
    
    % NOTE: assumption that the robots are always passed in in the same
    % order (otherwise we may need to control robot.identity)
    directions = RallyRobo.Direction.values;
    robot = game.add_robot([i j], directions(direction+1));
end
end
