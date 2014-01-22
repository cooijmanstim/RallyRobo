function [game, tiles] = Backupfunction( DataStructure, PlayersPos )

width = size(DataStructure,2);
heigth = size(DataStructure,1);

tiles = zeros(width, heigth, 12);

for j=1:width
    for i = 1:heigth
       
        x = DataStructure(i,j);
            %check if there is an object at x
            numOfdigits = (1 + floor(log10(abs(x))));
            %if x has more than 2 digits there are multiple objects)
            for k = 1:ceil(numOfdigits/2)
                if((1 + floor(log10(abs(x)))) > 2)
                    y=rem(x,100);
                    x=floor(x/100);
                else
                    y = x;
                end  
                tiles = PlaceObjects(tiles,i,j,y);
                    
            end                    
    end
end

%Convert element in Playerpos to positives.
for i = 1:length(PlayersPos)
    if(PlayersPos(i) < 0)
        PlayersPos(i) = PlayersPos(i) * -1;
    end
end

%17-20 represent 1st robot facing respectively right up left down
%21-24 represent 2nd robot facing respectively right up left down
%25-28 represent 3rd robot facing respectively right up left down
%29-32 represent 4th robot facing respectively right up left down
for s=1:length(PlayersPos)
    x = PlayersPos(s);
    %n is the number of digits in x
    n = (1 + floor(log10(abs(x))));
    orient = floor(x/10^(n-1));
    r = rem(x,10^(n-1));
    i = ceil(r/width);
    j = r-(floor(r/width)*width);
    if(j==0)
        j = width;
    end
    k = (4*(3+s))+orient;
    tiles(i,j,k)=1;
end


game = createDataStructure(tiles);


end

