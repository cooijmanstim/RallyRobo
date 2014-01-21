function [  ] = drawCheckpoints(checkpoints,n)
hold on;

resize = 0.1;
% TODO: make checkpoint indices 0-based in java
for i = 1: checkpoints.size()-1
    yx = double(checkpoints.get(i));
    y = yx(1);
    x = yx(2);
    file = strcat('images/CHK_',num2str(i),'.JPG');
    image = imread(file);
            xs = [x+resize,x+1-resize];
        ys = [y+resize,y+1-resize];
        imagesc(xs,fliplr(ys),image);
end
end
