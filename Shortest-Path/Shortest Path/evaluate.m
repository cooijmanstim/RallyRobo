function [ cards ] = evaluate( allpaths, flagpos )
%EVALUATE Summary of this function goes here
%   end pos = the end position of the robot after he played the 5 cards
%   flag pos = the position we desire
%   cards = the cards to play with their value
    
%danger(endpos) = the risk you take by standing on a certain tile. i.e.
%ending on a conveyer belt could be riskier than ending on a normal tile
cards = [];
    for i = 1:size(allpaths,1)
        value = abs(allpaths(i,(6))-flagpos(1)) + abs(allpaths(i,(7))-flagpos(2)); %+ danger(endpos);

        cards = [cards;allpaths(i,:) value];
        %cards = [cards;allpaths(i,:), value];
    end
end

