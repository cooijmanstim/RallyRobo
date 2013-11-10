#include "point.hpp"
#include "direction.hpp"
#include "robot.hpp"

Robot::Robot(Point position, DirectionIndex direction, CheckpointIndex next_checkpoint)
  : position(position), direction(direction), next_checkpoint(next_checkpoint) {
}
