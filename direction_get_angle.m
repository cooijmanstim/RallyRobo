function [angle] = direction_get_angle(dx)
angle = mod(atan2(dx(1), dx(2)) + 2*pi, 2*pi);
