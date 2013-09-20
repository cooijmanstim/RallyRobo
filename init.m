function [] = init()
% gets the environment in order

global RR;
% for constants and other things we need in many places
RR = [];

% indices of tile features (for the third dimension of the board matrix)
RR.tfi = generate_tile_feature_indices();
RR.nfeatures = length(fieldnames(RR.tfi));

RR.cards = generate_cards();

% directions (ENWS) and their integer representations
RR.dir = generate_directions();
RR.ndirections = length(fieldnames(RR.dir));
RR.directions = load('directions.mat');
