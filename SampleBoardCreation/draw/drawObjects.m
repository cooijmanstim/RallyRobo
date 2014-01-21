function [ ] = drawObjects( board )
import RallyRobo.Feature;

directions = RallyRobo.Direction.ordinals;

widthWalls = 0.33;

images = [];

scale = 101/68;
height = 0.45;
width = height*scale;
images.conveyor.plain = generate_conveyor_images(imread('images/conveyorEast.png'), height, width, directions);

scale = 112/114;
height = 0.75;
width = height*scale;
images.conveyor.cw = generate_conveyor_images(imread('images/conveyorEastClockwise.png'), height, width, directions);

scale = 126/118;
height = 0.65;
width = height*scale;
images.conveyor.ccw = generate_conveyor_images(imread('images/conveyorEastCounterclockwise.png'), height, width, directions);

images.repair = imread('images/repair.png');

for y = 1:board.interiorHeight
    for x = 1:board.interiorWidth
        ij = [y x];
       
        if board.has_feature(ij, Feature.Pit)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board.has_feature(ij, Feature.WallEast)
            rectX = [x+1-widthWalls,x+1,x+1,x+1-widthWalls];
            rectY = [y,y,y+1,y+1];
            fill(rectX,rectY,'black');
        end
        if board.has_feature(ij, Feature.WallNorth)
            rectX = [x+1,x+1,x,x];
            rectY = [y+1-widthWalls,y+1,y+1,y+1-widthWalls];
            fill(rectX,rectY,'black');
        end
        if board.has_feature(ij, Feature.WallWest)
            rectX = [x+widthWalls,x+widthWalls,x,x];
            rectY = [y,y+1,y+1,y];
            fill(rectX,rectY,'black');
        end
        if board.has_feature(ij, Feature.WallSouth)
            rectX = [x,x+1,x+1,x];
            rectY = [y,y,y+widthWalls,y+widthWalls];
            fill(rectX,rectY,'black');
        end
        if board.has_feature(ij, Feature.Repair)
            resize = 0.02;
			[xShift,yShift] = getShiftedValues(board,ij);
            imagesc([x+xShift+resize,x+xShift+1-resize],[y+yShift+1-resize,y+yShift+resize], images.repair);
        end
        
        if board.has_feature(ij, Feature.ConveyorTurningCw)
            conveyor_type = 'cw';
        elseif board.has_feature(ij, Feature.ConveyorTurningCcw)
            conveyor_type = 'ccw';
        else
            conveyor_type = 'plain';
        end

        for direction = directions(:)'
            if board.has_feature(ij, direction_conveyor(direction))
                image = images.conveyor.(conveyor_type){1+direction};
                [xShift,yShift] = getShiftedValues(board,ij);
                xs = x + xShift + 0.5 + 0.5*image.width*[-1 1];
                ys = y + yShift + 0.5 + 0.5*image.height*[-1 1];
            
                % imagesc flips the image vertically, so compensate for that by
                % flipping the ys
                h = imagesc(xs, fliplr(ys), image.rgbdata);
                set(h, 'AlphaData', image.alphadata);
            end
        end
    end
end
end
