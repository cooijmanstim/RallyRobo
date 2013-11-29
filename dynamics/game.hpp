#pragma once

#include <vector>

#include <boost/multi_array.hpp>

#include "point.hpp"
#include "direction.hpp"
#include "checkpoint.hpp"
#include "robot.hpp"
#include "card.hpp"

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

  FeatureIndex wallsByDirection[] = {
    WallEast, WallNorth, WallWest, WallSouth,
  };

  FeatureIndex conveyorsByDirection[] = {
    ConveyorEast, ConveyorNorth, ConveyorWest, ConveyorSouth,
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

  const Point robot_position(RobotIndex irobot);
  void set_robot_position(RobotIndex irobot, Point x);
  const DirectionIndex robot_direction(RobotIndex irobot);
  void set_robot_direction(RobotIndex irobot, DirectionIndex dir);

  const bool has_feature(Point x, FeatureIndex i);
  void set_feature(Point x, FeatureIndex i);

  const bool robot_can_leave(RobotIndex irobot, Point x, DirectionIndex dir);
  const bool robot_can_enter(RobotIndex irobot, Point x, DirectionIndex dir);
  bool robot_move_maybe(RobotIndex irobot, DirectionIndex dir);

  void process_card(RobotIndex irobot, Card card);
  void advance_conveyors();
};
