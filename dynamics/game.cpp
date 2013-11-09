#include "game.hpp"
#include <assert.h>

inline bool Game::has_feature(Point x, FeatureIndex i) {
  return board[x[0]][x[1]][i];
}

#define HF(FEATURE) has_feature(x, FEATURE)
bool Game::robot_can_leave(RobotIndex irobot, Point x, DirectionIndex dir) {
  if (HF(Pit))
    return false;

  switch (dir) {
  case Direction::East:  return HF(WallEast);
  case Direction::North: return HF(WallNorth);
  case Direction::West:  return HF(WallWest);
  case Direction::South: return HF(WallSouth);
  default: assert(false);
  }
}

bool Game::robot_can_enter(RobotIndex irobot, Point x, DirectionIndex dir) {
  switch (dir) {
  case Direction::East:  return HF(WallWest);
  case Direction::North: return HF(WallSouth);
  case Direction::West:  return HF(WallEast);
  case Direction::South: return HF(WallNorth);
  default: assert(false);
  }
}
#undef HF

/* Move the indicated robot in the direction 'dx', pushing other robots
 * if they are in the way.  Does not move if the move is obstructed or
 * would involve pushing a robot through an obstruction.
 * returns true if anything was moved.
 * Modifies game.
 */
bool Game::robot_move_maybe(RobotIndex irobot, DirectionIndex dir) {
  Point x = robots[irobot].position;

  Point xnew(x);
  xnew += Direction::asPoints[dir];

  if (!robot_can_leave(irobot, x,    dir) ||
      !robot_can_enter(irobot, xnew, dir)) {
    return false;
  }

  /* if there is a robot at the destination, try to push it */
  for (RobotIndex jrobot = 0; jrobot < robots.size(); jrobot++) {
    if (robots[jrobot].position == xnew) {
      if (!robot_move_maybe(jrobot, dir))
        return false;
      break;
    }
  }

  /* finally, move irobot */
  robots[irobot].position = xnew;
  return true;
}
