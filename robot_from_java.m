function [robot] = robot_from_java(jrobot)
robot = [];
robot.identity = jrobot.identity;
robot.position = jrobot.position;
robot.direction = jrobot.direction;
robot.respawn_position = jrobot.respawn_position;
robot.respawn_direction = jrobot.respawn_direction;
robot.next_checkpoint = jrobot.next_checkpoint;
robot.damage = jrobot.damage;
robot.state = jrobot.state;
robot.is_virtual = jrobot.is_virtual;
robot.registers = jrobot.registers;