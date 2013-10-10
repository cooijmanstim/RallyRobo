function [feature, index] = identifyTileFeatures(tile,samples,featuresSamples)
index = 0;
feature = zeros(1,size(featuresSamples,2));

sampleSize = size(samples,2);
% The actual identification algorithm

    [i,j] = find(tile);
    tile = tile(min(i):max(i),min(j):max(j));
    
    % Resize to be sampleSize x sampleSize
    
    
    %for each digit, S(v) represents the degree of matching
    for  s= 1:sampleSize
        sampleTileSizeX = size(samples{s},2);
        sampleTileSizeY = size(samples{s},1);
        tileTest = imresize(tile,[sampleTileSizeX sampleTileSizeY]);
        sample = samples(s);
        S(s) = sum(sum(tileTest.*sample));
    end
    index = find(S == max(S),1);
    feature = featuresSamples(index);
    
    %         if (Plocal(k,3) == 5 || Plocal(k,3) == 6) && abs(S(5) - S(6)) < 0.1 %If it's a 5 or 6, use the Euler number
    %             E = regionprops(tile,'EulerNumber');
    %             if ~E(1).EulerNumber
    %                 Plocal(k,3) = 6;
    %             end
    %         end
    

    %keyboard
end
