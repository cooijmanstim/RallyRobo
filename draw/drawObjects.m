function [ ] = drawObjects( board )
global RR;

widthWalls = 0.15;

images = [];

scale = 101/68;
height = 0.5;
width = height*scale;
images.conveyor.plain = generate_conveyor_images(imread('images/conveyorEast.png'), height, width, RR.directions.asrows);

scale = 112/114;
height = 0.7;
width = height*scale;
images.conveyor.cw = generate_conveyor_images(imread('images/conveyorEastClockwise.png'), height, width, RR.directions.asrows);

scale = 126/118;
height = 0.7;
width = height*scale;
images.conveyor.ccw = generate_conveyor_images(imread('images/conveyorEastCounterclockwise.png'), height, width, RR.directions.asrows);

images.repair = imread('images/repair.png');

for y = 1:board_height(board)
    for x = 1:board_width(board)
        ij = [y x];
       
        if board_has_feature(board, ij, RR.features.pit)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, ij, RR.features.wall_east)
            rectX = [x+1-widthWalls,x+1,x+1,x+1-widthWalls];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, ij, RR.features.wall_north)
            rectX = [x+1,x+1,x,x];
            rectY = [y+1-widthWalls,y+1,y+1,y+1-widthWalls];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, ij, RR.features.wall_west)
            rectX = [x+widthWalls,x+widthWalls,x,x];
            rectY = [y,y+1,y+1,y];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, ij, RR.features.wall_south)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+widthWalls,y+widthWalls];
            fill(rectX,rectY,'black');
        end
        if board_has_feature(board, ij, RR.features.repair)
            resize = 0.2;
            imagesc([x+resize,x+1-resize],[y+resize,y+1-resize], images.repair);
        end
        
        if board_has_feature(board, ij, RR.features.conveyor_turning_clockwise)
            conveyor_type = 'cw';
        elseif board_has_feature(board, ij, RR.features.conveyor_turning_counterclockwise)
            conveyor_type = 'ccw';
        else
            conveyor_type = 'plain';
        end

        features = RR.features.conveyor_east:RR.features.conveyor_south;
        for feature = features(board_has_feature(board, ij, features))
            dx = RR.directions.asrows(1 + feature - RR.features.conveyor_east, :);
            image = images.conveyor.(conveyor_type){2+dx(1), 2+dx(2)};
            
            xs = x + 0.5 + 0.5*image.width*[-1 1];
            ys = y + 0.5 + 0.5*image.height*[-1 1];
            
            % imagesc flips the image vertically, so compensate for that by
            % flipping the ys
            h = imagesc(xs, fliplr(ys), image.rgbdata);
            set(h, 'AlphaData', image.alphadata);
        end
    end
end
end
