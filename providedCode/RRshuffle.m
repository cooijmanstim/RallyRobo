function a=RRshuffle(id,total,round)
% ROBORALLY SHUFFLE (84 cards) v.1.01, 19/09/2013, copyright UM/FHS/DKE/NSO 
% id is nmb of player, and total[] contains the nmb of cards each receive.

% The cards in Roborally are numbered 1 to 84 (times 10):
% Move 3 (6 cards) 79...84	
% Move 2 (12)      67...78
% Move 1 (18)      49...66
% Back up (6)      43...48 
% Rotate right (18) 8...42, even numbers
% Rotate left (18)  7...41, odd numbers
% U-turn (6)        1...6
rng(round+9041956); % initialization random generator 
a=[]; if total(id)==0, return; end % no cards to be returned
b=1:84; % the deck
for i=1:sum(total(1:id))
    c=ceil(rand*(85-i)); %  random nmb between 1 and 85-i
    a=[a,b(c)]; % a random card is drawn from the deck
    b(c:84-i)=b(c+1:85-i); % remaining deck (cards after 84-i are invalid) 
end
a=a(end-total(id)+1:end); % the last total(id) drawn cards