#pragma once

#include "point.hpp"

#include <vector>

namespace Direction {
  enum DirectionIndex {
    East, North, West, South,
  };

  const DirectionIndex indices[] = {
    East, North, West, South,
  };
  
  const Point asPoints[] = {
    Point( 0,  1),
    Point( 1,  0),
    Point( 0, -1),
    Point(-1,  0),
  };
}

typedef Direction::DirectionIndex DirectionIndex;
