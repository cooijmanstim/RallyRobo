function [corner] = ExternalCorners(x)


xmin=x(1,1);
xminIndex=1;

xmax=x(2,1);
xmaxIndex=1;

ymin=x(1,2);
yminIndex=1;

ymax=x(2,2);
ymaxIndex=1;

for i=1:size(x,1)
    if x(i,1)<=xmin
        xmin=x(i,1);
        xminIndex=i;
    end
end

for i=1:size(x,1)
    if x(i,1)>=xmax
        xmax=x(i,1);  
        xmaxIndex=i;
    end       
end

for i=1:size(x,1)
    if x(i,2)<=ymin
        ymin=x(i,2);
        yminIndex=i;
    end
end
    
for i=1:size(x,1)
    if x(i,2)>=ymax
        ymax=x(i,2);
        ymaxIndex=i;
    end
end



%top left
corner (1,1) =x(xminIndex,1);
corner (1,2) =x(yminIndex,2);

%top right
corner (2,1) =x(xmaxIndex,1);
corner (2,2) =x(yminIndex,2);

%bottom left
corner (3,1) =x(xminIndex,1);
corner (3,2) =x(ymaxIndex,2);

%bottom right
corner (4,1) =x(xmaxIndex,1);
corner (4,2) =x(ymaxIndex,2);

end