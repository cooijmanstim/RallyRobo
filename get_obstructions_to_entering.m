function [tfis] = get_obstructions_to_entering(dx)
% FIXME: this is currently both horribly implemented and broken. i'll do it
% properly later.
global RR;
tfis = [RR.tfi.wall_east+mod(get_direction_angle(dx)+pi, 2*pi)*2/pi];
