function [isGamestate, featureOrGamestate] = identifyTileFeatures(tile)
global TFM;
index = 0;


sampleSize = size(TFM.featuresets,1)+size(TFM.gamestates,1);
feature = zeros(1,sampleSize);
% The actual identification algorithm

sampleTileSize = size(TFM.tiles{1});
tileTest = imresize(tile,sampleTileSize);
S=zeros(sampleSize,1);

%for each digit, S(v) represents the degree of matching
for  s= 1:sampleSize
    sample = TFM.tiles{s};
    S(s) = sum(sum(tileTest == sample));
end

maxs = max(S);
index = find(S == maxs,1);
% figure
% subplot(1,2,1), imshow(tileTest)
% subplot(1,2,2), imshow(TFM.tiles{index})
if index < 213
    featureOrGamestate = TFM.featuresets(index,:);
    isGamestate= 0;
else
    featureOrGamestate = TFM.gamestates(index+1-213);
    isGamestate = 1;
end

%keyboard
end
