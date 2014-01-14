function [  ] = drawCheckpoints(checkpoints,n)
hold on;

% TODO: make checkpoint indices 0-based in java
for i = 1: checkpoints.size()-1
    yx = double(checkpoints.get(i));
    y = yx(1);
    x = yx(2);
    text(x+0.375,y+0.5,num2str(i),'FontSize',getFontSize(n));
end
end
