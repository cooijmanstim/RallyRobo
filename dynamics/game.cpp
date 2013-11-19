#include <assert.h>
#include <vector>
#include <algorithm>
#include <boost/assign/list_of.hpp>

#include "card.hpp"
#include "game.hpp"

using namespace std;
using namespace boost::assign;

Game::Game(vector<Robot> robots, vector<Point> checkpoints)
  : robots(robots), checkpoints(checkpoints),
    board(boost::extents[BOARD_WIDTH+2][BOARD_HEIGHT+2][Feature::NFeatures]) {
  // add a border of pits around the board.  this obviates the need to deal with bounds explicitly.
  // the coordinates for the interior of the board are now 1-based.
  for (int i = 0; i < BOARD_HEIGHT+2; i++) {
    board[i][0][Feature::Pit] = 1;
    board[i][BOARD_HEIGHT+1][Feature::Pit] = 1;
  }
  for (int j = 0; j < BOARD_WIDTH+2; j++) {
    board[0][j][Feature::Pit] = 1;
    board[BOARD_WIDTH+1][j][Feature::Pit] = 1;
  }
}

Game::Game(const Game& that)
  : robots(that.robots), checkpoints(that.checkpoints), board(that.board) {
}

Game::~Game() {
}

Game& Game::operator=(const Game &that) {
  this->robots = that.robots;
  this->checkpoints = that.checkpoints;
  this->board = that.board;
  return *this;
}

Game Game::example_game() {
  Game game(list_of<Robot>(Point( 3,  1), Direction::East,  0)
                          (Point( 4, 11), Direction::South, 0)
                          (Point( 8,  1), Direction::South, 0)
                          (Point(11,  9), Direction::West,  0),
            list_of<Point>(12, 1) (8, 9) (2, 8) (9, 5));

  // set feature at points
  auto sfap = [&game](FeatureIndex fi, vector<Point> points) {
    for_each(points.begin(), points.end(),
             [&game, &fi] (Point x) {
               game.set_feature(Point(x[1], x[0]), fi);
             });
  };

  sfap(Feature::Pit,                list_of<Point>(8,5) (9,5) (3,7) (6,10));
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

const bool Game::has_feature(Point x, FeatureIndex i) {
  return board[x[0]][x[1]][i];
}

void Game::set_feature(Point x, FeatureIndex i) {
  board[x[0]][x[1]][i] = 1;
}

const Point Game::robot_position(RobotIndex irobot) {
  return robots[irobot].position;
}

void Game::set_robot_position(RobotIndex irobot, Point x) {
  robots[irobot].position = x;
}

const bool Game::robot_can_leave(RobotIndex irobot, Point x, DirectionIndex dir) {
  if (has_feature(x, Feature::Pit))
    return false;

  switch (dir) {
  case Direction::East:  return !has_feature(x, Feature::WallEast);
  case Direction::North: return !has_feature(x, Feature::WallNorth);
  case Direction::West:  return !has_feature(x, Feature::WallWest);
  case Direction::South: return !has_feature(x, Feature::WallSouth);
  default: assert(false);
  }
}

const bool Game::robot_can_enter(RobotIndex irobot, Point x, DirectionIndex dir) {
  switch (dir) {
  case Direction::East:  return !has_feature(x, Feature::WallWest);
  case Direction::North: return !has_feature(x, Feature::WallSouth);
  case Direction::West:  return !has_feature(x, Feature::WallEast);
  case Direction::South: return !has_feature(x, Feature::WallNorth);
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

void Game::game_process_card(RobotIndex irobot, Card card) {
  if (card.translation == 0) {
    // rotation only
    robots[irobot].direction = Direction::rotate(robots[irobot].direction, card.rotation);
  } else {
    // translation only, tile by tile
    DirectionIndex di = card.translation >= 0 ? robots[irobot].direction : Direction::opposite(robots[irobot].direction);
    for (int k = abs(card.translation); k >= 1; k--) {
      bool moved = robot_move_maybe(irobot, di);
      if (!moved)
        break;
    }
  }
}
