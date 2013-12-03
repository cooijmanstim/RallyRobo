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

Robot::Robot(const Robot& that)
  : identity(that.identity),
    position(that.position),
    direction(that.direction),
    respawn_position(that.respawn_position),
    respawn_direction(that.respawn_direction),
    next_checkpoint(that.next_checkpoint),
    damage(that.damage), state(that.state), is_virtual(that.is_virtual),
    registers(that.registers) {
}

Robot::~Robot() {
}

Robot& Robot::operator=(const Robot& that) {
  this->identity = that.identity;
  this->position = that.position;
  this->direction = that.direction;
  this->respawn_position = that.respawn_position;
  this->respawn_direction = that.respawn_direction;
  this->next_checkpoint = that.next_checkpoint;
  this->damage = that.damage;
  this->state = that.state;
  this->is_virtual = that.is_virtual;
  this->registers = that.registers;
  return *this;
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
