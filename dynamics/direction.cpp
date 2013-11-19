#include "direction.hpp"

DirectionIndex Direction::rotate(DirectionIndex a, Rotation da) {
  return static_cast<DirectionIndex>((a + da) % Direction::NDirections);
}

DirectionIndex Direction::opposite(DirectionIndex a) {
  return rotate(a, 2);
}
