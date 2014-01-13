function [] = init()
% gets the environment in order

javaaddpath('dynamics/java/bin');

% for constants and other things we need in many places
global RR;
RR = [];

% width and height of tiles; used in image processing. subject to change.
RR.tile_size = 64;

global TFM;
TFM = load('tile_featureset_map');
for i = 1:size(TFM.tiles);
TFM.tiles{i} = makeLogicalOfImage(TFM.tiles{i});
end

