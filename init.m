function [] = init()
% gets the environment in order

% for constants and other things we need in many places
global RR;
RR = [];

% indices of tile features (for the third dimension of the board matrix)
RR.features = generate_features();
RR.nfeatures = length(fieldnames(RR.features));

RR.cards = generate_cards();

RR.directions = generate_directions();
RR.ndirections = size(RR.directions.asrows, 1);

RR.obstructions = precompute_obstructions();

% width and height of tiles; used in image processing. subject to change.
RR.tile_size = 64;

% this is used to treat borders as pits
RR.borderfeatureset = ismember(1:RR.nfeatures, [RR.features.pit]);

global TFM;
TFM = load('tile_featureset_map');
for i = 1:size(TFM.tiles);
TFM.tiles{i} = makeLogicalOfImage(TFM.tiles{i});
end

