function [] = init()
% gets the environment in order

javaaddpath('dynamics/java/bin');

% for constants and other things we need in many places
global RR;
RR = [];

% width and height of tiles; used in image processing. subject to change.
RR.tile_size = 64;

RR.irobot_by_color.red   = 1;
RR.irobot_by_color.green = 2;
RR.irobot_by_color.blue  = 3;
RR.irobot_by_color.black = 4;
RR.irobot_by_color.pink  = 5;
