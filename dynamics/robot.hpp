#pragma once

#include "point.hpp"
#include "direction.hpp"
#include "game.hpp"

class Robot {
public:
  Point position;
  DirectionIndex direction;
  CheckpointIndex next_checkpoint;

  Robot(Point position, DirectionIndex direction, CheckpointIndex next_checkpoint);
};
