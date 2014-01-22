function [ Tiles ] = getTiles( im, gridSize )
%GETTILES Summary of this function goes here

[x,y] = size(im);
s=x/gridSize;
t=y/gridSize;

for i = 1:(gridSize)
    for j = 1:(gridSize)    
       
        %x
        Tiles((12*(i-1)+j),1) = i;
        %y
        Tiles((12*(i-1)+j),2) = j;
        %top left x
        Tiles((12*(i-1)+j),3) = 1+(i-1)*s;
        %top left y
        Tiles((12*(i-1)+j),4) = 1+(j-1)*t;
        
        %top right x
        Tiles((12*(i-1)+j),7) = 1+(i-1)*s;
        %top right y
        Tiles((12*(i-1)+j),8) = j*t+1;
        
        %bottom left x
        Tiles((12*(i-1)+j),5) = i*s+1;
        %bottom left y
        Tiles((12*(i-1)+j),6) = 1+(j-1)*t;
        
        %bottom right x
        Tiles((12*(i-1)+j),9) = i*s+1;
        %bottom right y
        Tiles((12*(i-1)+j),10) = j*t+1;

        
    end
end

