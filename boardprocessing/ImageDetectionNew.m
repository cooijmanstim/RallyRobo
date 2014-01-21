close all ; clear all;
%% to be placed in header
gridSize = 12;
game = RallyRobo.Game(gridSize, gridSize);
%% read the original image 

[im, map]= imread('screenshotBoard0121_2.PNG');

figure, imshow(im);
title('the original image');


%% convert to gray scale

im2=rgbtograyscale(im);

% figure, imshow(im2,map);
% title('convert to gray scale');


%% tresholding

threshold =135; 
im3 = relativeScaling(im2,2);

% figure, imshow(im3);
% title('thresholding');

%% noise removal

im2 = bwareaopen(im3,20000);

% figure, imshow(im2);
% title('Noise removal');

%% Clear the borders
im2 = imclearborder(im2);
% imshow(im2);


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

% figure, imshow(im2);
% title('Looking for corners');
% hold on
% plot(extcorner(:,1), extcorner(:,2), 'g*');


%% selcting the starting points
input_points =[extcorner(1,1) extcorner(1,2);...
               extcorner(2,1) extcorner(2,2);...
               extcorner(4,1) extcorner(4,2);...
               extcorner(3,1) extcorner(3,2)];

%% selcting the ending points
base_points=[10 10; 610 10;10 610; 610 610 ] ;

%% transforming the image
t = cp2tform(input_points, base_points,'projective');
baseX = base_points(: , 1);
baseY = base_points(: , 2);
y = imtransform(im, t , 'bilinear' , 'XData' , [min(baseX) max(baseX)] , 'YData',[min(baseY) max(baseY)]);


% figure, imshow(y);
% title('The transformed image');

imageRGB = y;


%% treshold the new image
threshold =115; 
% y = relativeScaling(y,2);
y = makeLogicalOfImage(y);
% figure, imshow(y);
%% remove the noise from the new image / GOD function
y = bwareaopen(y, 30);

% figure, imshow(y);
% title('removing noise again');

%% determine the gridsize


%% get the Array of tiles
tiles = getTiles(y, gridSize);

%shows only the bottom right corner of every tile
figure, imshow(y);
hold on;
plot(tiles(:,9), tiles(:,10), 'g*');


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
checkpoints = {};
for tile = tiles'
    % tile contains corner point coordinates
    x = tile(1);
    y = gridSize+1-tile(2);
    xmin = tile(3);
    ymin = tile(4);
    xmax = tile(end-1);
    ymax = tile(end);
    width = xmax - xmin;
    height = ymax - ymin;
    assert(all([width height] >= 0));
    croppedTile = imcrop(rotatedimage, [xmin ymin width height]);
    [isGamestate,featureOrGamestate] = identifyTileFeatures(croppedTile);
    if isGamestate
		if ~isempty(featureOrGamestate.robotdir)
			rgb = imcrop(imageRGB, [xmin ymin width height]);
            middle = round(size(rgb,1)/2);
			midPixel = rgb(middle,middle,:);
			player = getPlayerNumberOfColor(midPixel);
			robots{player} = featureOrGamestate;
		else
			checkpoints{featureOrGamestate.checkpointid} = [y x];
		end
	else
		game = board_enable_feature(game, [y x], featureOrGamestate );
    end
end
game = board_enable_robots(game,robots);
game = board_enable_checkpoints(game,checkpoints);
initBoardFigure(game);
refreshBoard(game);
