function [corner] = ExternalCornersHorizontal(x)


topLeft=100000;
topLeftIndex=-1;

botRight=0;
botRightIndex=-1;



for i=1:size(x,1)
    if x(i,1)+x(i,2)<topLeft
        topLeft = x(i,1)+x(i,2);
        topLeftIndex=i;
    end
    if x(i,1)+x(i,2)>botRight
        botRight = x(i,1)+x(i,2);
        botRightIndex=i;
    end
end




%top left
corner (1,1) =x(topLeftIndex,1);
corner (1,2) =x(topLeftIndex,2);

%bottom right
corner (4,1) =x(botRightIndex,1);
corner (4,2) =x(botRightIndex,2);

%diagonal vector as aid to construct square
diagX = x(botRightIndex,1)-x(topLeftIndex,1);
diagY = x(botRightIndex,2)-x(topLeftIndex,2);

%top right
corner (2,1) =x(topLeftIndex,1) + 0.5*diagX + 0.5*diagY;
corner (2,2) =x(topLeftIndex,2) + 0.5*diagY - 0.5*diagX;

%bottom left
corner (3,1) =x(topLeftIndex,1) + 0.5*diagX - 0.5*diagY;
corner (3,2) =x(topLeftIndex,2) + 0.5*diagY + 0.5*diagX;



end