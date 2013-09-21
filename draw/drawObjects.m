function [ ] = drawObjects( board )
% draws the walls
rows = size(board,1);
columns = size(board,2);
global RR;
widthWalls = 0.15;
hold on;
file = strcat('images/repair.png');
imageRepair = imread(file);
conveyorImageScale = 101/68;
conveyorImageHeight = 0.7;
conveyorImageWidth = conveyorImageHeight/conveyorImageScale;
conveyorImageCwScale = 112/114;
conveyorImageCwHeight = 0.7;
conveyorImageCwWidth = conveyorImageCwHeight/conveyorImageCwScale;
conveyorImageCCwScale = 112/114;
conveyorImageCCwHeight = 0.7;
conveyorImageCCwWidth = conveyorImageCCwHeight/conveyorImageCCwScale;
conveyorDistance = 0.2;
file = strcat('images/conveyorEast.png');
imageConveyorEast = imread(file);
file = strcat('images/conveyorEastClockwise.png');
imageConveyorEastClockwise = imread(file);
file = strcat('images/conveyorEastCounterclockwise.png');
imageConveyorEastCounterclockwise = imread(file);
for x = 1:columns
    for y = 1:rows
        if board(x,y,RR.tfi.pit)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board(x,y,RR.tfi.wall_east)
            rectX = [x+1-widthWalls,x+1,x+1,x+1-widthWalls];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board(x,y,RR.tfi.wall_north)
            rectX = [x+1,x+1,x,x];
            rectY = [y-widthWalls,y,y,y-widthWalls];
            fill(rectX,rectY,'black');
        end
        if board(x,y,RR.tfi.wall_west)
            rectX = [x+widthWalls,x+widthWalls,x,x];
            rectY = [y,y+1,y+1,y];
            fill(rectX,rectY,'black');
        end
         if board(x,y,RR.tfi.wall_south)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+widthWalls,y+widthWalls];
            fill(rectX,rectY,'black');
         end
         if board(x,y,RR.features.repair)
             resize = 0.2;
             imagesc([x+resize,x+1-resize],[y+resize,y+1-resize],imageRepair);
         end
         if board(x,y,RR.features.conveyor_turning_clockwise)
             convImage = imageConveyorEastClockwise;
             width = conveyorImageCwWidth;
             height = conveyorImageCwHeight;
         elseif board(x,y,RR.features.conveyor_turning_counterclockwise)
             convImage = imageConveyorEastCounterclockwise;
             width = conveyorImageCCwWidth;
             height = conveyorImageCCwHeight;
         else
             convImage = imageConveyorEast;
             width = conveyorImageWidth;
             height = conveyorImageHeight;
         end
         if board(x,y,RR.features.conveyor_east)
             imagesc([x+conveyorDistance,x+conveyorDistance+height],[y+0.5+0.5*width,y+0.5-0.5*width],convImage);
         elseif board(x,y,RR.features.conveyor_north)
             rotated = imrotate(convImage,-90);
             imagesc([x+0.5+0.5*width,x+0.5-0.5*width],[y+conveyorDistance,y+conveyorDistance+height],rotated);
         elseif board(x,y,RR.features.conveyor_west)
             imagesc([x+1-conveyorDistance,x+1-conveyorDistance-height],[y+0.5+0.5*width,y+0.5-0.5*width],convImage);
         elseif board(x,y,RR.features.conveyor_south)
            rotated = imrotate(convImage,-90);
            imagesc([x+0.5+0.5*width,x+0.5-0.5*width],[y+conveyorDistance+height,y+conveyorDistance],rotated);
         end
    end
end
end

