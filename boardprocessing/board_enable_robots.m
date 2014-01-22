function [game] = board_enable_robots(game,robots)
directions = RallyRobo.Direction.values;
for i = 1 : game.robots.size
        robot = game.robots.get(i-1);
        if size(robots{i},1)>0
            robot.position = robots{i}.position;
            robot.direction = directions(robots{i}.robotdir+1);
        end
end
end