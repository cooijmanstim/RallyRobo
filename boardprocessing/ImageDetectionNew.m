close all ; clear all;

%% read the original image 

[im, map]= imread('ourBoardJan14.PNG');

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

figure, imshow(y);
title('The transformed image');

imageRGB = y;

% %% treshold the new image
% 
% threshold = 4;
% y = relativeScaling(y,threshold);
% 
% figure, imshow(y);
% title('thresholding the grayscale transformed image');
 

%%
threshold =135; 
y = relativeScaling(y,2);
% y = makeLogicalOfImageWithThreshold(y,threshold);
% figure, imshow(y);
%% remove the noise from the new image / GOD function
y = bwareaopen(y, 30);

% figure, imshow(y);
% title('removing noise again');

%% determine the gridsize
gridSize = 12;

%% get the Array of tiles
tiles = getTiles(y, gridSize);

%shows only the bottom right corner of every tile
% figure, imshow(y);
% hold on;
% plot(tiles(:,9), tiles(:,10), 'g*');


%% create board from tiles
global RR;
init();
%initiate sample tiles
global TFM;
TFM = load('tile_featureset_map');
for i = 1:size(TFM.tiles);
TFM.tiles{i} = makeLogicalOfImage(TFM.tiles{i});
end
game = RallyRobo.Game(gridSize, gridSize);
rotatedimage = y;
for tile = tiles'
    % tile contains corner point coordinates
    x = tile(1);
    y = tile(2);
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
           midPixel = rgb(m,m,:);
           player = getPlayerNumberOfColor(midPixel);
       end
    end
    game = board_enable_feature_or_gamestate(game, [y x],isGamestate,featureOrGamestate,player );
end
initBoardFigure(game);
refreshBoard(game.board, game.state.robots, game.state.checkpoints);
