function [] = Backupfunction( game, DataStructure, PlayersPos )
featuresets = backupfunction_featuresets();

height = game.board.interiorHeight;
width = game.board.interiorWidth;

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
                game.board.checkpoints.set(y, int32([i j]));
            else
                for h = 1:length(featuresets{y})
                    feature = featuresets{y}(h);
                    game.board.set_feature([i j], feature);
                end
            end
        end                    
    end
end

for s=1:length(PlayersPos)
    x = PlayersPos(s);
    robot = game.robots.get(s-1);
    
    if x == 0
        robot.destroy();
        continue;
    end

    if x < 0
        robot.virtualize();
        x = -x;
    end
    
    %n is the number of digits in x
    n = (1 + floor(log10(abs(x))));
    direction = floor(x/10^(n-1));
    r = rem(x,10^(n-1));
    i = ceil(r/width);
    j = r-(floor(r/width)*width);
    if(j==0)
        j = width;
    end
    
    % flip vertical axis
    i = height - i + 1;
    
    directions = RallyRobo.Direction.values;
    robot.position = [i j];
    robot.direction = directions(direction);
end
end
