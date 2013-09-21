function [o] = precompute_obstructions()
global RR;

% the components of direction vectors can be nonpositive, so an offset has
% to be added to them in order for them to be used as indices into these
% data structures.  to avoid bugs, use the functions o.leave(dx) and
% o.enter(dx) rather than performing manual lookups in o.leave_ and
% o.enter_.

xzero = 2; yzero = 2;
o.leave_ = cell(3, 3); o.enter_ = cell(3, 3);

% add the walls
for dy = [-1 0 1]
    for dx = [-1 0 1]
        y = yzero + dy; x = xzero + dx;

        offset = RR.features.wall_east;
        direction = [dy dx];
        
        wall = round(offset+direction_get_angle(direction)*2/pi);
        o.leave_{y, x} = [wall RR.features.pit];
        
        wall = round(offset+direction_get_angle(-direction)*2/pi);
        o.enter_{y, x} = wall;
    end
end

% XXX: these anonymous functions might be slower than if they were defined
% in their own file, but then yzero and xzero would have to be communicated
% somehow. we will see later how big of a problem the current situation is
% to performance.
o.leave = @(dx) o.leave_{dx(1) + yzero, dx(2) + xzero};
o.enter = @(dx) o.enter_{dx(1) + yzero, dx(2) + xzero};
