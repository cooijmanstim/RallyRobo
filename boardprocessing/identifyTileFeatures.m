function [isGamestate, featureOrGamestate] = identifyTileFeatures(tile)
global TFM;
index = 0;


sampleSize = size(TFM.tiles,1);
feature = zeros(1,sampleSize);
% The actual identification algorithm

sampleTileSize = size(TFM.tiles{1});
tileTest = imresize(tile,sampleTileSize);
S=zeros(sampleSize,1);

%for each digit, S(v) represents the degree of matching
jitter = 4; % has to be even number
for  s= 1:sampleSize
    sample = TFM.tiles{s};
    for i = 1:jitter
        for j = 1:jitter
            sNew = sum(sum(tileTest(i:end-jitter+i,j:end-jitter+j) == sample(jitter/2:end-jitter/2,jitter/2:end-jitter/2)));
            if sNew > S(s)
                S(s) = sNew;
            end
        end
    end
end

maxs = max(S);
index = find(S == maxs,1);
if index < 213
    featureOrGamestate = TFM.featuresets(index,:);
    isGamestate= 0;
else
    featureOrGamestate = TFM.gamestates(index+1-213);
    isGamestate = 1;
end

%keyboard
end
