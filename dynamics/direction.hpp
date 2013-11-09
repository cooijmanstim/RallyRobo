#pragma once

#include "point.hpp"

#include <vector>

using namespace std;

namespace Direction {
  enum DirectionIndex {
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
