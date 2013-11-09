#include "game.hpp"
#include <assert.h>

Game::Game(vector<Robot> robots, vector<Point> checkpoints) : robots(robots), checkpoints(checkpoints) {
}

inline bool Game::has_feature(Point x, FeatureIndex i) {
  return board[x[0]][x[1]][i];
}

inline void Game::set_feature(Point x, FeatureIndex i) {
  board[x[0]][x[1]][i] = 1;
}

#define HF(FEATURE) has_feature(x, FEATURE)
bool Game::robot_can_leave(RobotIndex irobot, Point x, DirectionIndex dir) {
  if (HF(Feature::Pit))
    return false;

  switch (dir) {
  case Direction::East:  return HF(Feature::WallEast);
  case Direction::North: return HF(Feature::WallNorth);
  case Direction::West:  return HF(Feature::WallWest);
  case Direction::South: return HF(Feature::WallSouth);
  default: assert(false);
  }
}

bool Game::robot_can_enter(RobotIndex irobot, Point x, DirectionIndex dir) {
  switch (dir) {
  case Direction::East:  return HF(Feature::WallWest);
  case Direction::North: return HF(Feature::WallSouth);
  case Direction::West:  return HF(Feature::WallEast);
  case Direction::South: return HF(Feature::WallNorth);
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
