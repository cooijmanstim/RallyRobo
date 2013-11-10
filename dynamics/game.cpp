#include "game.hpp"
#include <assert.h>

#include <vector>
#include <algorithm>
#include <boost/assign/list_of.hpp>

using namespace std;
using namespace boost::assign;

Game::Game(vector<Robot> robots, vector<Point> checkpoints) : robots(robots), checkpoints(checkpoints) {
}

Game Game::example_game() {
  Game game(list_of<Robot>(Point(3, 1), Direction::North, 0),
            list_of<Point>(12, 1) (8, 9) (2, 8) (9, 5));

  // set feature at points
  auto sfap = [&game](FeatureIndex fi, vector<Point> points) {
    for_each(points.begin(), points.end(),
             [&game, &fi] (Point x) {
               game.set_feature(x, fi);
             });
  };

  sfap(Feature::Pit,                list_of<Point>(8, 5) (9, 5) (3, 7) (6, 10));
  sfap(Feature::Repair,             list_of<Point>(2,1) (2,5) (5,3) (9,3) (5,8) (1,10));
  sfap(Feature::ConveyorNorth,      list_of<Point>(3,1) (3,2) (3,3) (7,4) (7,5));
  sfap(Feature::ConveyorEast,       list_of<Point>(3,4) (4,4) (5,4) (6,4) (7,6) (8,6) (9,6) (10,6) (11,6) (12,6));
  sfap(Feature::ConveyorWest,       list_of<Point>(1,6) (2,6) (3,6) (4,6) (5,7) (6,7) (7,7) (8,7) (9,7) (10,7) (11,7) (12,7));
  sfap(Feature::ConveyorSouth,      list_of<Point>(4,7));
  sfap(Feature::ConveyorTurningCcw, list_of<Point>(7,4) (4,7));
  sfap(Feature::ConveyorTurningCw,  list_of<Point>(7,6) (3,4) (4,6));
  sfap(Feature::WallEast,           list_of<Point>(4,5));
  sfap(Feature::WallNorth,          list_of<Point>(10,2) (4,5) (7,7) (3,10));
  sfap(Feature::WallWest,           list_of<Point>(4,1) (10,2) (7,3) (1,5) (11,9) (5,12));
  sfap(Feature::WallSouth,          list_of<Point>(6,1));

  return game;
}

const inline bool Game::has_feature(Point x, FeatureIndex i) {
  return board[x[0]][x[1]][i];
}

inline void Game::set_feature(Point x, FeatureIndex i) {
  board[x[0]][x[1]][i] = 1;
}

const bool Game::robot_can_leave(RobotIndex irobot, Point x, DirectionIndex dir) {
  if (has_feature(x, Feature::Pit))
    return false;

  switch (dir) {
  case Direction::East:  return has_feature(x, Feature::WallEast);
  case Direction::North: return has_feature(x, Feature::WallNorth);
  case Direction::West:  return has_feature(x, Feature::WallWest);
  case Direction::South: return has_feature(x, Feature::WallSouth);
  default: assert(false);
  }
}

const bool Game::robot_can_enter(RobotIndex irobot, Point x, DirectionIndex dir) {
  switch (dir) {
  case Direction::East:  return has_feature(x, Feature::WallWest);
  case Direction::North: return has_feature(x, Feature::WallSouth);
  case Direction::West:  return has_feature(x, Feature::WallEast);
  case Direction::South: return has_feature(x, Feature::WallNorth);
  default: assert(false);
  }
}

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
