#pragma once

#include <vector>

#include "point.hpp"
#include "direction.hpp"

#define BOARD_SIZE 12

using namespace std;

typedef unsigned char CheckpointIndex;
typedef unsigned char RobotIndex;

#include "robot.hpp"

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
  vector<Robot> robots;
  vector<Point> checkpoints;

public:
  static Game example_game();

  Game(vector<Robot> robots, vector<Point> checkpoints);

  Point robot_position(RobotIndex i);
  bool has_feature(Point x, FeatureIndex i);
  void set_feature(Point x, FeatureIndex i);
  bool robot_can_leave(RobotIndex irobot, Point x, DirectionIndex dir);
  bool robot_can_enter(RobotIndex irobot, Point x, DirectionIndex dir);
  bool robot_move_maybe(RobotIndex irobot, DirectionIndex dir);
};
