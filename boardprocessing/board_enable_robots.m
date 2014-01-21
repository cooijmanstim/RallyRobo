function [game] = board_enable_robots(game,robots)
directions = RallyRobo.Direction.values;
counter = 1;
for robot = robots
        robot = game.robots.get(counter-1);
        game.add_robot(robot.position, directions(robot.robotdir+1));
        counter = counter +1;
end