function [] = init()

% for constants and other things we need in many places
global RR;
RR = [];

% width and height of tiles; used in image processing. subject to change.
RR.tile_size = 64;
