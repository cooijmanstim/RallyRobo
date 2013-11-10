#include "point.hpp"
#include "direction.hpp"
#include "robot.hpp"

Robot::Robot(Point position, DirectionIndex direction, CheckpointIndex next_checkpoint)
  : position(position), direction(direction), next_checkpoint(next_checkpoint) {
}

Robot::Robot(const Robot& that)
  : position(that.position),
    direction(that.direction),
    next_checkpoint(that.next_checkpoint) {
}

Robot::~Robot() {
}

Robot& Robot::operator=(const Robot& that) {
  this->position = that.position;
  this->direction = that.direction;
  this->next_checkpoint = that.next_checkpoint;
  return *this;
}
