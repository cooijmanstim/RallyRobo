function [cards] = generate_cards()
cards = struct('priority', {}, 'translation', {}, 'rotation', {});

% u-turn cards
for p = 10:10:60
    cards(end+1).priority = p;
    cards(end).translation = zeros(1, 2);
    cards(end).rotation = -eye(2);
end

% counterclockwise rotation cards
for p = 70:20:410
    cards(end+1).priority = p;
    cards(end).translation = zeros(1, 2);
    cards(end).rotation = [0 -1; 1 0];
end

% clockwise rotation cards
for p = 80:20:420
    cards(end+1).priority = p;
    cards(end).translation = zeros(1, 2);
    cards(end).rotation = [0 1; -1 0];
end

% back up
for p = 430:10:480
    cards(end+1).priority = p;
    cards(end).translation = -1;
    cards(end).rotation = eye(2);
end

% move 1 forward
for p = 490:10:660
    cards(end+1).priority = p;
    cards(end).translation = 1;
    cards(end).rotation = eye(2);
end

% move 2 forward
for p = 670:10:780
    cards(end+1).priority = p;
    cards(end).translation = 2;
    cards(end).rotation = eye(2);
end

% move 3 forward
for p = 790:10:840
    cards(end+1).priority = p;
    cards(end).translation = 3;
    cards(end).rotation = eye(2);
end
