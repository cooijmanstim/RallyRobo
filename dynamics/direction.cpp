#include "direction.hpp"

DirectionIndex Direction::rotate(DirectionIndex a, Rotation da) {
  return static_cast<DirectionIndex>((a + da + Direction::NDirections) % Direction::NDirections);
}

DirectionIndex Direction::opposite(DirectionIndex a) {
  return rotate(a, 2);
}

// true if one or more steps in direction dir from point a lead to point b
bool Direction::connects(const Point& a, DirectionIndex dir, const Point& b) {
  const Point& dx = Direction::asPoints[dir];
  return
    (a[0] == b[0] && dx[0] == 0 && (b[1] - a[1])/dx[1] > 0) ||
    (a[1] == b[1] && dx[1] == 0 && (b[0] - a[0])/dx[0] > 0);
}
