function [corner] = ExternalCorners(x)


xmin=x(1,1);

xmax=x(1,1);

ymin=x(1,2);

ymax=x(1,2);

for i=1:size(x,1)
    if x(i,1)<=xmin
        xmin=x(i,1);
    end
    if x(i,1)>=xmax
        xmax=x(i,1);
    end
    if x(i,2)<=ymin
        ymin=x(i,2);
    end
    if x(i,2)>=ymax
        ymax=x(i,2);
    end
end



% upper left corner
corner (1,1) = xmin;
corner (1,2) = ymin;

% upper right corner
corner (2,1) = xmin;
corner (2,2) = ymax;

% lower left corner
corner (3,1) = xmax;
corner (3,2) = ymin;

% lower right corner
corner (4,1) = xmax;
corner (4,2) = ymax;

end