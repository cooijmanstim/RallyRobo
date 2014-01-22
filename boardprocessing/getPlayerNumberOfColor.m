function [ playerNumber ] = getPlayerNumberOfColor( rgb,featureOrGamestate )

% searching for best position to take colored pixel
middleX = round(size(rgb,1)/2);
middleY = middleX;
switch featureOrGamestate.robotdir
    case 0
        middleX = round(middleX*1.5);
    case 1
        middleY = round(middleY *0.5);
    case 2
        middleX = round(middleX*0.5);
    case 3
        middleY = round(middleY *1.5);
end

color = rgb(middleX,middleY,:);

% now choosing which color it is
if color(1) > color(2) & color(1) > color(3)*2 % red
    playerNumber = 1;
elseif color(2) > color(1) & color(2) > color(3) % green
    playerNumber = 2;
elseif color(3) > color(2) & color(3) > color(1)*2 % blue
    playerNumber = 3;
elseif color(1) <40 & color(2) < 40 & color(3) < 40 % black
    playerNumber = 4;
else   % pink
    playerNumber = 5;
    
end