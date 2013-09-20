function [tfis] = get_obstructions_to_leaving(dx)
% FIXME: this is currently both horribly implemented and broken. i'll do it
% properly later.
global RR;
tfis = [RR.tfi.wall_east+get_direction_angle(dx)*2/pi RR.tfi.pit];
