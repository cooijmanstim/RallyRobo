function [ game ] = getGameFromImage( image, game )

gridSize = game.board.interiorHeight;
%% convert to gray scale

im2=rgbtograyscale(image);
%% tresholding
im3 = relativeScaling(im2,2);

%% noise removal

im2 = bwareaopen(im3,20000);

%% Clear the borders
im2 = imclearborder(im2);

%% finding corners
R = regionprops(im2,'Area','BoundingBox','PixelList');
NR = numel(R);

maxArea = 0;
for x = 1:NR
    A(x) = prod(R(x).BoundingBox(3:4));
    if R(x).Area > maxArea
        maxArea = R(x).Area;
        kmax = x;
    end
end
DIAG1 = sum(R(kmax).PixelList,2);
DIAG2 = diff(R(kmax).PixelList,[],2);

[m,dUL] = min(DIAG1);    [m,dDR] = max(DIAG1);
[m,dDL] = min(DIAG2);    [m,dUR] = max(DIAG2);

extcorner = R(kmax).PixelList([dUL dDL dDR dUR dUL],:);

%% selecting the starting points
input_points =[extcorner(1,1) extcorner(1,2);...
               extcorner(2,1) extcorner(2,2);...
               extcorner(4,1) extcorner(4,2);...
               extcorner(3,1) extcorner(3,2)];

%% selecting the ending points
sizePerTile = 64;
transformationSize = gridSize * sizePerTile-1;
base_points=[0 0; transformationSize 0;0 transformationSize; transformationSize transformationSize ] ;

%% transforming the original image
t = cp2tform(input_points, base_points,'projective');
baseX = base_points(: , 1);
baseY = base_points(: , 2);
y = imtransform(image, t , 'bilinear' , 'XData' , [min(baseX) max(baseX)] , 'YData',[min(baseY) max(baseY)]);

%% save a rgb image for color detection
imageRGB = y;


%% treshold the new image
y = makeLogicalOfImage(y);
%% remove the noise from the new image / GOD function
y = bwareaopen(y, 30);

%% get the Array of tiles
tiles = getTiles(y, gridSize);

%% create board from tiles
global RR;
init();
%initiate sample tiles
global TFM;
TFM = load('tile_featureset_map');
for i = 1:size(TFM.tiles);
TFM.tiles{i} = makeLogicalOfImage(TFM.tiles{i});
end
rotatedimage = y;
%new robots and checkpoints have to be stored separately to initialize them in the right order
robots = {};
robots{game.robots.size} = [];
checkpoints = {};
checkpoints{game.board.checkpoints.size} = [];
counter = 0;
for tile = tiles'
    counter = counter+1;
    % tile contains corner point coordinates
    x = tile(1);
    y = gridSize+1-tile(2);
    xmin = tile(3);
    ymin = tile(4);
    xmax = tile(end-1);
    ymax = tile(end);
    width = xmax - xmin-1;
    height = ymax - ymin-1;
    assert(all([width height] >= 0));
    croppedTile = imcrop(rotatedimage, [xmin ymin width height]);
    [isGamestate,featureOrGamestate] = identifyTileFeatures(croppedTile);
    if isGamestate
		if ~isempty(featureOrGamestate.robotdir)
			rgb = imcrop(imageRGB, [xmin ymin width height]);
			player = getPlayerNumberOfColor(rgb,featureOrGamestate);
            if player ~=-1
                robots{player} = featureOrGamestate;
                robots{player}.position = [y x];
            end
        else
			checkpoints{featureOrGamestate.checkpointid} = [y x];
		end
	else
		game = board_enable_feature(game, [y x], featureOrGamestate );
    end
end
game = board_enable_robots(game,robots);
game = board_enable_checkpoints(game,checkpoints);
end