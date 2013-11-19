#pragma once

#include <vector>

#include <boost/multi_array.hpp>

#include "point.hpp"
#include "direction.hpp"
#include "checkpoint.hpp"
#include "robot.hpp"

#define BOARD_WIDTH 12
#define BOARD_HEIGHT 12

typedef unsigned char RobotIndex;

namespace Feature {
#define FEATURES Pit, Repair, WallEast, WallNorth, WallWest, WallSouth, \
                 ConveyorEast, ConveyorNorth, ConveyorWest, ConveyorSouth, \
                 ConveyorTurningCw, ConveyorTurningCcw
  enum FeatureIndex {
    FEATURES,
    NFeatures,
  };

  FeatureIndex features[] = {
    FEATURES
  };
#undef FEATURES
}
typedef Feature::FeatureIndex FeatureIndex;

typedef boost::multi_array<char, 3> Board;
typedef Board::index BoardIndex;

class Game {
  std::vector<Robot> robots;
  std::vector<Point> checkpoints;
  Board board;

public:
  static Game example_game();

  Game(std::vector<Robot> robots, std::vector<Point> checkpoints);

  Game(const Game& that);
  ~Game();
  Game &operator=(const Game &that);

  const Point robot_position(RobotIndex i);
  const bool has_feature(Point x, FeatureIndex i);
  void set_feature(Point x, FeatureIndex i);
  const bool robot_can_leave(RobotIndex irobot, Point x, DirectionIndex dir);
  const bool robot_can_enter(RobotIndex irobot, Point x, DirectionIndex dir);
  bool robot_move_maybe(RobotIndex irobot, DirectionIndex dir);
};
