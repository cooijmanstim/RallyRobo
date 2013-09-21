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
