function [ Tiles ] = getTiles( C, gridSize )
%GETTILES Summary of this function goes here
%   C has the four outer corner points on which we determine the
%   inner tiles

%s = (TRy-TLy)/gridsize
s=(C(2,1)-C(1,1))/gridSize;
t=(C(3,2)-C(2,2))/gridSize;

gridSize = 12;
for i = 1:(gridSize)
    for j = 1:(gridSize)    
       
        %x
        Tiles((12*(i-1)+j),1) = i;
        %y
        Tiles((12*(i-1)+j),2) = j;
        %top left x
        Tiles((12*(i-1)+j),3) = (i-1)*s+C(1,1);
        %top left y
        Tiles((12*(i-1)+j),4) = (j-1)*t+C(1,2);
        
        %top right x
        Tiles((12*(i-1)+j),7) = (i-1)*s+C(1,1);
        %top right y
        Tiles((12*(i-1)+j),8) = j*t+C(1,2);
        
        %bottom left x
        Tiles((12*(i-1)+j),5) = i*s+C(1,1);
        %bottom left y
        Tiles((12*(i-1)+j),6) = (j-1)*t+C(1,2);
        
        %bottom right x
        Tiles((12*(i-1)+j),9) = i*s+C(1,1);
        %bottom right y
        Tiles((12*(i-1)+j),10) = j*t+C(1,2);

        
    end
end

