function [ ] = drawObjects( board )
% draws the walls
rows = size(board,1);
columns = size(board,2);
global RR;
width = 0.15;
hold on;
for x = 1:columns
    for y = 1:rows
        if board(x,y,RR.tfi.pit)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board(x,y,RR.tfi.wall_east)
            rectX = [x+1-width,x+1,x+1,x+1-width];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board(x,y,RR.tfi.wall_north)
            rectX = [x+1,x+1,x,x];
            rectY = [y-width,y,y,y-width];
            fill(rectX,rectY,'black');
        end
        if board(x,y,RR.tfi.wall_west)
            rectX = [x+width,x+width,x,x];
            rectY = [y,y+1,y+1,y];
            fill(rectX,rectY,'black');
        end
         if board(x,y,RR.tfi.wall_south)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+width,y+width];
            fill(rectX,rectY,'black');
         end
         if board(x,y,RR.tfi.repair)
             resize = 0.2;
             file = strcat('images/repair.png');
             image = imread(file);
             imagesc([x+resize,x+1-resize],[y+resize,y+1-resize],image);
         end
    end
end
end

