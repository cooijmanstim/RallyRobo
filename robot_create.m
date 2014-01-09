function [robot] = robot_create(identity, position, direction)
robot = [];
robot.identity = identity;
robot.position = position;
robot.direction = direction;

% hopefully sensible defaults for the rest
global RR;
robot.respawn_position = position;
robot.respawn_direction = direction;
robot.next_checkpoint = 1;
robot.damage = 0;
robot.state = RR.states.active;
robot.is_virtual = false;
robot.registers = zeros(1, RR.nregisters);
