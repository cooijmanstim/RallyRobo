function [] = robots_to_java(robots, jgame)
for i = 1:length(robots)
    robot = robots(i);
    jrobot = jgame.add_robot(robot.position, robot.direction);
    jrobot.respawn_position = robot.respawn_position;
    jrobot.respawn_direction = robot.respawn_direction;
    jrobot.next_checkpoint = robot.next_checkpoint;
    jrobot.damage = robot.damage;
    jrobot.state = robot.state;
    jrobot.is_virtual = robot.is_virtual;
    jrobot.registers = robot.registers;
end
