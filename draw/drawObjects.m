function [ ] = drawObjects( board )
global RR;

widthWalls = 0.15;

scale = 101/68;
height = 0.5;
width = height*scale;
conveyorImages = generate_conveyor_images(imread('images/conveyorEast.png'), height, width, RR.directions.asrows);

scale = 112/114;
height = 0.7;
width = height*scale;
conveyorImagesCw = generate_conveyor_images(imread('images/conveyorEastClockwise.png'), height, width, RR.directions.asrows);

scale = 126/118;
height = 0.7;
width = height*scale;
conveyorImagesCCw = generate_conveyor_images(imread('images/conveyorEastCounterclockwise.png'), height, width, RR.directions.asrows);

repairImage = imread('images/repair.png');

for y = 1:board_height(board)
    for x = 1:board_width(board)
        if board_has_feature(board, [y x], RR.features.pit)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [y x], RR.features.wall_east)
            rectX = [x+1-widthWalls,x+1,x+1,x+1-widthWalls];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [y x], RR.features.wall_north)
            rectX = [x+1,x+1,x,x];
            rectY = [y+1-widthWalls,y+1,y+1,y+1-widthWalls];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [y x], RR.features.wall_west)
            rectX = [x+widthWalls,x+widthWalls,x,x];
            rectY = [y,y+1,y+1,y];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [y x], RR.features.wall_south)
           rectX = [x,x+1,x+1,x];
           rectY = [y,y,y+widthWalls,y+widthWalls];
           fill(rectX,rectY,'black');
        end
        if board_has_feature(board, [y x], RR.features.repair)
            resize = 0.2;
            imagesc([x+resize,x+1-resize],[y+resize,y+1-resize],repairImage);
        end
        
        if board_has_feature(board, [y x], RR.features.conveyor_turning_clockwise)
            imageContainer = conveyorImagesCw;
        elseif board_has_feature(board, [y x], RR.features.conveyor_turning_counterclockwise)
            imageContainer = conveyorImagesCCw;
        else
            imageContainer = conveyorImages;
        end

        features = RR.features.conveyor_east:RR.features.conveyor_south;
        for feature = features(board_has_feature(board, [y x], features))
            dx = RR.directions.asrows(1 + feature - RR.features.conveyor_east, :);
            conveyorImage = imageContainer{2+dx(1), 2+dx(2)};
            
            xs = x + 0.5 + 0.5*conveyorImage.width*[-1 1];
            ys = y + 0.5 + 0.5*conveyorImage.height*[-1 1];
            
            % imagesc flips the image vertically, so compensate for that by
            % flipping the ys
            h = imagesc(xs, fliplr(ys), conveyorImage.rgbdata);
            set(h, 'AlphaData', conveyorImage.alphadata);
        end
    end
end
end
