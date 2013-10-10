toCheck = makeLogicalOfImage(imread('test.bmp'));
[tiles,featuresets] = generate_tile_images();

[features,index] =identifyTileFeatures(toCheck,tiles,featuresets)