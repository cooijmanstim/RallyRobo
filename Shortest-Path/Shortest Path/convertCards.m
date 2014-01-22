function [ combination ] = convertCards( v )
%CONVERTCARDS Summary of this function goes here
%   Detailed explanation goes here
hand = zeros(1,7);
combination = [];
for i = 1:length(v) 
    if(v(i) >= 79 && v(i)<=84)
        hand(1) = hand(1) + 1;
        combination = [combination 1];
    end
    if(v(i) >= 67 && v(i)<=78)
        hand(2) = hand(2) + 1;
         combination = [combination 2];
    end
    if(v(i) >= 49 && v(i)<=66)
        hand(3) = hand(3) + 1;
         combination = [combination 3];
    end
    if(v(i) >= 43 && v(i)<=48)
        hand(4) = hand(4) + 1;
         combination = [combination 4];
    end
    if(v(i) >= 7 && v(i)<=42 && rem(v(i),2) == 0)
        hand(5) = hand(5) + 1;
         combination = [combination 5];
    end
    if(v(i) >= 7 && v(i)<=42 && rem(v(i),2) == 1)
        hand(6) = hand(6) + 1;
         combination = [combination 6];
    end
    if(v(i) >= 1 && v(i)<=6)
        hand(7) = hand(7) + 1;
         combination = [combination 7];
    end        
end

end

