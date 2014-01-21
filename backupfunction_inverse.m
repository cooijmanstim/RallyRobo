function [DataStructure, PlayersPos] = backupfunction_inverse(game)
[featuresets, featureset_order] = backupfunction_featuresets();

width = game.board.interiorWidth;
height = game.board.interiorHeight;

DataStructure = zeros(height, width);
lindex = @(ij) width*(height-ij(1))+ij(2);

for k = 1:game.board.checkpoints.size()-1
    checkpoint = game.board.checkpoints.get(k);
    i = 1+height-checkpoint(1);
    j = checkpoint(2);
    DataStructure(i, j) = DataStructure(i, j)*100 + k;
end

% use a working copy of the game for bookkeeping to avoid double-counting
% features in this crazy encoding
game = game.clone();
for i=1:height
    for j=1:width
        i2 = 1+height-i;
        for k=featureset_order
            featureset = featuresets{k};
            if ~isempty(featureset) && all(arrayfun(@(f) game.board.has_feature(i, j, f), featureset))
                DataStructure(i2, j) = DataStructure(i2, j) * 100 + k;
                arrayfun(@(f) game.board.unset_feature(i, j, f), featureset);
            end
        end
    end
end

PlayersPos = zeros(1, game.robots.size());
for i=1:length(PlayersPos)
    robot = game.robots.get(i-1);
    li = lindex(robot.position);
    
    if li >= 100
        factor = 1000;
    elseif li >= 10
        factor = 100;
    else
        factor = 10;
    end
    
    PlayersPos(i) = (robot.direction.ordinal()+1) * factor + li;
end
end
