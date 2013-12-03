#pragma once

#include <vector>

#include <boost/multi_array.hpp>
#include <boost/shared_ptr.hpp>

#include "point.hpp"
#include "direction.hpp"
#include "features.hpp"
#include "checkpoint.hpp"
#include "robot.hpp"
#include "card.hpp"

typedef boost::multi_array<char, 3> Board;
typedef Board::index BoardIndex;

class Game {
  static const unsigned int BoardWidth = 12, BoardHeight = 12;

  bool over;
  RobotIndex winner;

  std::vector<boost::shared_ptr<Robot> > robots;
  std::vector<Point> checkpoints;
  Board board;

public:
  static Game example_game();

  Game();

  Game(const Game& that);
  ~Game();
  Game &operator=(const Game &that);

  void add_robot(Point initial_position, DirectionIndex initial_direction);
  void add_checkpoint(Point checkpoint);

  bool out_of_bounds(const Point &x) const;
  bool has_feature(const Point &x, FeatureIndex i) const;
  void set_feature(const Point &x, FeatureIndex i);

  bool any_robot_obstructing(const Point &x, boost::optional<boost::shared_ptr<Robot> > exception) const;
  bool robot_can_leave(Robot &robot, const Point &x, DirectionIndex dir) const;
  bool robot_can_enter(Robot &robot, const Point &x, DirectionIndex dir) const;

  bool robot_move_maybe(Robot &robot, DirectionIndex dir);
  void process_card(Robot &robot, Card &card);
  void advance_conveyors();
  void fire_robot_lasers();
  void remove_destroyed_robots();
  void respawn_waiting_robots();
  void devirtualize_robots();
  void promote_robots();
  void repair_robots();
  void perform_turn();
};
