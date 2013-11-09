#pragma once

#include <vector>

#include "point.hpp"
#include "direction.hpp"

#define BOARD_SIZE 12

using namespace std;

typedef unsigned char CheckpointIndex;
typedef unsigned char RobotIndex;

typedef struct {
  Point position;
  DirectionIndex direction;
  CheckpointIndex next_checkpoint;
} Robot;

class Game {
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

  char board[BOARD_SIZE][BOARD_SIZE][NFeatures];
  vector<Robot> robots;
  vector<Point> checkpoints;

public:
  Game(vector<Robot> robots, vector<Point> checkpoints);

  Point robot_position(RobotIndex i);
  bool has_feature(Point x, FeatureIndex i);
  bool robot_can_leave(RobotIndex irobot, Point x, DirectionIndex dir);
  bool robot_can_enter(RobotIndex irobot, Point x, DirectionIndex dir);
  bool robot_move_maybe(RobotIndex irobot, DirectionIndex dir);
};
