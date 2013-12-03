#pragma once

#include "point.hpp"
#include "card.hpp"

#include <vector>

// XXX: this is becoming a weird beast.

namespace Direction {
  #define DIRECTIONS East, North, West, South
  enum DirectionIndex {
    DIRECTIONS,
    NDirections,
  };

  const DirectionIndex indices[] = {
    DIRECTIONS
  };
  
  const Point asPoints[] = {
    Point( 0,  1),
    Point( 1,  0),
    Point( 0, -1),
    Point(-1,  0),
  };

  DirectionIndex rotate(DirectionIndex a, Rotation da);
  DirectionIndex opposite(DirectionIndex a);
  bool connects(const Point& a, DirectionIndex dir, const Point& b);
}

typedef Direction::DirectionIndex DirectionIndex;
