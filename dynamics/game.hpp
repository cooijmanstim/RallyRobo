#pragma once

#include <vector>

#include "point.hpp"
#include "direction.hpp"
#include "checkpoint.hpp"
#include "robot.hpp"

#define BOARD_SIZE 12

typedef unsigned char RobotIndex;

namespace Feature {
  enum FeatureIndex {
    Pit,
    Repair,
    WallEast,
    WallNorth,
    WallWest,
    WallSouth,
    ConveyorEast,
    ConveyorNorth,
    ConveyorWest,
    ConveyorSouth,
    ConveyorTurningCw,
    ConveyorTurningCcw,
    NFeatures,
  };
}
typedef Feature::FeatureIndex FeatureIndex;

class Game {
  char board[BOARD_SIZE][BOARD_SIZE][Feature::NFeatures];
  std::vector<Robot> robots;
  std::vector<Point> checkpoints;

public:
  static Game example_game();

  Game(std::vector<Robot> robots, std::vector<Point> checkpoints);

  const Point robot_position(RobotIndex i);
  const bool has_feature(Point x, FeatureIndex i);
  void set_feature(Point x, FeatureIndex i);
  const bool robot_can_leave(RobotIndex irobot, Point x, DirectionIndex dir);
  const bool robot_can_enter(RobotIndex irobot, Point x, DirectionIndex dir);
  bool robot_move_maybe(RobotIndex irobot, DirectionIndex dir);
};
