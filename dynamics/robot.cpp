#include <algorithm>

#include "point.hpp"
#include "direction.hpp"
#include "robot.hpp"

Robot::Robot(RobotIndex identity, Point position, DirectionIndex direction)
  : identity(identity),
    position(position), direction(direction),
    respawn_position(position), respawn_direction(direction),
    next_checkpoint(0),
    damage(0), state(Active), is_virtual(false)
{
}

Robot::~Robot() {
}

bool Robot::is_active() { return state == Active; }
bool Robot::is_waiting() { return state == Waiting; }
bool Robot::is_destroyed() { return state == Destroyed; }

bool Robot::obstructs() {
  return !is_virtual && state != Waiting;
}

void Robot::rotate(Rotation dd) {
  direction = Direction::rotate(direction, dd);
}

void Robot::take_damage() {
  damage++;
  if (damage >= 10)
    state = Destroyed;
}

void Robot::wait() {
  state = Waiting;
}

void Robot::respawn() {
  position = respawn_position;
  direction = respawn_direction;
  damage = 0;
  state = Active;
}

void Robot::virtualize() {
  is_virtual = true;
}

void Robot::devirtualize() {
  is_virtual = false;
}

void Robot::repair() {
  damage = std::max(0U, damage - 1);
}
