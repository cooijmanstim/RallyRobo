function [angle] = direction_get_angle(direction)
angle = atan2(direction(1), direction(2));
