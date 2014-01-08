function [feature, gamestate] = identifyTileFeatures(tile)
global TFM;
index = 0;


sampleSize = size(TFM.featuresets,1);
feature = zeros(1,sampleSize);
% The actual identification algorithm

%     [i,j] = find(tile);
%     tile = tile(min(i):max(i),min(j):max(j));

% Resize to be sampleSize x sampleSize

sampleTileSize = size(TFM.tiles{1});
tileTest = imresize(tile,sampleTileSize);
S=zeros(sampleSize,1);

%for each digit, S(v) represents the degree of matching
for  s= 1:sampleSize
    sample = TFM.tiles{s};
    S(s) = sum(sum(tileTest == sample));
end
index = find(S == max(S),1);
feature = TFM.featuresets(index,:);
gamestate = TFM.gamestates(index);

%         if (Plocal(k,3) == 5 || Plocal(k,3) == 6) && abs(S(5) - S(6)) < 0.1 %If it's a 5 or 6, use the Euler number
%             E = regionprops(tile,'EulerNumber');
%             if ~E(1).EulerNumber
%                 Plocal(k,3) = 6;
%             end
%         end


%keyboard
end
