function [x,y] = getShiftedValues( board,ij )
import RallyRobo.Feature;
shift = 0.17;
x = 0;
y = 0;
if board.has_feature(ij, Feature.WallEast)
    x = x-shift;
end
if board.has_feature(ij, Feature.WallNorth)
    y = y-shift;
end
if board.has_feature(ij, Feature.WallWest)
    x = x+shift;
end
if board.has_feature(ij, Feature.WallSouth)
    y = y+shift;
end
end