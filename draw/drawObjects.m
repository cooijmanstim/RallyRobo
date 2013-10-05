function [ ] = drawObjects( board )
global RR;

widthWalls = 0.15;
conveyorImageScale = 101/68;
conveyorImageHeight = 0.7;
conveyorImageWidth = conveyorImageHeight/conveyorImageScale;
conveyorImageCwScale = 112/114;
conveyorImageCwHeight = 0.7;
conveyorImageCwWidth = conveyorImageCwHeight/conveyorImageCwScale;
conveyorImageCCwScale = 112/114;
conveyorImageCCwHeight = 0.7;
conveyorImageCCwWidth = conveyorImageCCwHeight/conveyorImageCCwScale;

images = [];
for s = {'repair' 'conveyorEast' 'conveyorEastClockwise' 'conveyorEastCounterclockwise'}
    kack = s{1};
    images.(kack) = imread(sprintf('images/%s.png', kack));
end

for i = 1:board_height(board)
    for j = 1:board_width(board)
        x = i; y = j;
        
        if board_has_feature(board, [x y], RR.features.pit)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [x y], RR.features.wall_east)
            rectX = [x+1-widthWalls,x+1,x+1,x+1-widthWalls];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [x y], RR.features.wall_north)
            rectX = [x+1,x+1,x,x];
            rectY = [y+1-widthWalls,y+1,y+1,y+1-widthWalls];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [x y], RR.features.wall_west)
            rectX = [x+widthWalls,x+widthWalls,x,x];
            rectY = [y,y+1,y+1,y];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [x y], RR.features.wall_south)
           rectX = [x,x+1,x+1,x];
           rectY = [y,y,y+widthWalls,y+widthWalls];
           fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [x y], RR.features.repair)
            resize = 0.2;
            imagesc([x+resize,x+1-resize],[y+resize,y+1-resize],images.repair);
        end
        if board_has_feature(board, [x y], RR.features.conveyor_turning_clockwise)
            convImage = images.conveyorEastClockwise;
            width = conveyorImageCwWidth;
            height = conveyorImageCwHeight;
        elseif board_has_feature(board, [x y], RR.features.conveyor_turning_counterclockwise)
            convImage = images.conveyorEastCounterclockwise;
            width = conveyorImageCCwWidth;
            height = conveyorImageCCwHeight;
        else
            convImage = images.conveyorEast;
            width = conveyorImageWidth;
            height = conveyorImageHeight;
        end
        
        if board_has_feature(board, [x y], RR.features.conveyor_east)
        elseif board_has_feature(board, [x y], RR.features.conveyor_north)
            convImage = imrotate(convImage,90);
            [width, height] = deal(height, width);
        elseif board_has_feature(board, [x y], RR.features.conveyor_west)
            convImage = imrotate(convImage, 180);
        elseif board_has_feature(board, [x y], RR.features.conveyor_south)
            convImage = imrotate(convImage,-90);
            [width, height] = deal(height, width);
        end
        [width,height] = deal(height, width);

        if any(board_has_feature(board, [x y], RR.features.conveyor_east:RR.features.conveyor_south))
            xs = x + 0.5 + 0.5*width*[-1 1];
            ys = y + 0.5 + 0.5*height*[-1 1];
            
            % imagesc flips the image vertically, so compensate for that
            convImage = convImage(fliplr(1:end), :, :);
            
            imagesc(xs, ys, convImage);
        end
    end
end
end
