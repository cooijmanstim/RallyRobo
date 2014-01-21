function [ playerNumber ] = getPlayerNumberOfColor( color )

if isInColorRange(color,[255,0,0])
    playerNumber = 1;
elseif isInColorRange(color,[0,255,0])
    playerNumber = 2;
elseif isInColorRange(color,[4,152,252])
    playerNumber = 3;
elseif isInColorRange(color,[0,0,0])
    playerNumber = 4;
elseif isInColorRange(color,[255,100,255])
    playerNumber = 5;
else
playerNumber = 5;

end