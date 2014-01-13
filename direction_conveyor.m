function [f] = direction_conveyor(direction)
v = RallyRobo.Direction.values;
d = v(1+direction);
f = d.conveyor;
