% toCheck = makeLogicalOfImage(imread('test.bmp'));
% toCheck = makeLogicalOfImage(imread('test2.gif'));
toCheck = makeLogicalOfImage(imread('test4.gif'));
% [tiles,featuresets] = generate_tile_images();
global TFM;
TFM = load('tile_featureset_map');
for i = 1:size(TFM.tiles);
TFM.tiles{i} = makeLogicalOfImage(TFM.tiles{i});
end



[features, gamestate] =identifyTileFeatures(toCheck);