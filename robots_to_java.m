function [] = robots_to_java(robots, jgame)
import RallyRobo.Direction;
import RallyRobo.Robot;

for i = 1:length(robots)
    robot = robots(i);
    jrobot = jgame.add_robot(robot.position, Direction.fromOrdinal(robot.direction));
    jrobot.respawn_position = robot.respawn_position;
    jrobot.respawn_direction = Direction.fromOrdinal(robot.respawn_direction);
    jrobot.next_checkpoint = robot.next_checkpoint;
    jrobot.damage = robot.damage;
    jrobot.state = Robot.stateFromOrdinal(robot.state);
    jrobot.is_virtual = robot.is_virtual;
    jrobot.registers = robot.registers;
end
