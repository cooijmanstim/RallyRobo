function [corner] =OuterCorners(x)


xmin=x(1,1);
xminIndex=1;

xmax=x(2,1);
xmaxIndex=1;

ymin=x(1,2);
yminIndex=1;

ymax=x(2,2);
ymaxIndex=1;

%look for the smallest x in the fisrt col
for i=1:size(x,1)
    if x(i,1)<=xmin
        xmin=x(i,1);
        xminIndex=i;
    end
end

%look for the biggest x in the fisrt col

for i=1:size(x,1)
    if x(i,1)>=xmax
        xmax=x(i,1);  
        xmaxIndex=i;
    end       
end

%look for the smallest y in the second col
for i=1:size(x,1)
    if x(i,2)<=ymin
        ymin=x(i,2);
        yminIndex=i;
    end
end
%look for the smallest y in the second col 
for i=1:size(x,1)
    if x(i,2)>=ymax
        ymax=x(i,2);
        ymaxIndex=i;
    end
end


%angolo in alto sinistra
corner (1,1) =x(xminIndex,1);%coordinata x
corner (1,2) =x(ymaxIndex,2);%coordinata Y

%angolo in basso a desta

corner (4,1) =x(xmaxIndex,1);
corner (4,2) =x(yminIndex,2);

%angolo in alto a destra
corner (2,1) =corner (4,1);
corner (2,2) =corner (1,2);

%angolo in basso a sinista
corner (3,1) =corner (1,1);
corner (3,2) =corner (4,2) ;



end