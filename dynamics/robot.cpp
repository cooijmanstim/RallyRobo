#include <algorithm>

#include <boost/none.hpp>

#include "point.hpp"
#include "direction.hpp"
#include "robot.hpp"

Robot::Robot(RobotIndex identity, Point position, DirectionIndex direction)
  : identity(identity),
    position(position), direction(direction),
    respawn_position(position), respawn_direction(direction),
    next_checkpoint(1),
    damage(0), state(Active), is_virtual(false)
{
}

Robot::~Robot() {
}

bool Robot::is_active()    const { return state == Active; }
bool Robot::is_waiting()   const { return state == Waiting; }
bool Robot::is_destroyed() const { return state == Destroyed; }

bool Robot::obstructs() const {
  return !is_virtual && state != Waiting;
}

bool Robot::can_shoot() const {
  return is_active() && !is_virtual;
}

bool Robot::can_take_damage() const {
  return is_active() && !is_virtual;
}

void Robot::rotate(Rotation dd) {
  direction = Direction::rotate(direction, dd);
}

void Robot::take_damage() {
  damage++;
  if (damage > MaximumDamage)
    destroy();
}

void Robot::repair() {
  damage = std::max(0U, damage - 1);
}

void Robot::destroy() {
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
  // always respawn as virtual; the robot will be devirtualized if necessary
  // after all respawns are complete.  this way simultaneous respawns can be
  // handled independently.
  virtualize();
}

void Robot::virtualize() {
  is_virtual = true;
}

void Robot::devirtualize() {
  is_virtual = false;
}

Deck Robot::vacate_registers() {
  Deck cards;
  int ni = std::min(NRegisters, MaximumDamage - damage);
  for (int i = 0; i < ni; i++) {
    cards.insert(*registers[i]);
    registers[i] = boost::none;
  }
  return cards;
}

// http://stackoverflow.com/a/4891102
const size_t Robot::NRegisters;
