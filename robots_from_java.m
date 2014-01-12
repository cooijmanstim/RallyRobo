function [robots] = robots_from_java(jrobots)
robots = [];
for i = 1:jrobots.size()
    robots(end+1) = robot_from_java(jrobots.get(i));
end
