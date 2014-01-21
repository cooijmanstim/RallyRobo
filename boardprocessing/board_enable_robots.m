function [game] = board_enable_robots(game,robots)
directions = RallyRobo.Direction.values;
for i = 1:5
	if ~isempty(robots{i})
        game.state.robots.direction = featureOrCheckpoint.robotdir;
		game.add_robot(robots{i}.position, directions(robots{i}.robotdir+1));
	end
end
end