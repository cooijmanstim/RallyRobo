function [] = init()
% gets the environment in order

global RR;
% for constants and other things we need in many places
RR = [];

% indices of tile features (for the third dimension of the board matrix)
tfi = load('tfi.mat');
RR.tfi = tfi.tfi; % matlab stinks big time
RR.nfeatures = length(fieldnames(RR.tfi));

% directions (ENWS) and their integer representations
dir = load('dir.mat');
RR.dir = dir.dir; % snore
RR.ndirections = length(fieldnames(RR.dir));
RR.directions = load('directions.mat');