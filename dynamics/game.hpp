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

  Deck deck;

public:
  static Game example_game();

  Game();
  ~Game();

  void add_robot(Point initial_position, DirectionIndex initial_direction);
  boost::shared_ptr<Robot> get_robot(RobotIndex i) const;
  std::vector<boost::shared_ptr<Robot> > get_robots() const;

  void add_checkpoint(Point checkpoint);

  bool out_of_bounds(const Point &x) const;
  bool has_feature(const Point &x, FeatureIndex i) const;
  void set_feature(const Point &x, FeatureIndex i);

  bool any_robot_obstructing(const Point &x, boost::optional<boost::shared_ptr<Robot> > exception) const;
  bool robot_can_move(Robot &robot, DirectionIndex dir) const;
  bool robot_move_maybe(Robot &robot, DirectionIndex dir);

  void advance_conveyors();
  void fire_robot_lasers();
  void remove_destroyed_robots();
  void respawn_waiting_robots();
  void devirtualize_robots();
  void promote_robots();
  void repair_robots();

  void process_card(Robot &robot, const Card &card);
  void perform_turn();

  void fill_empty_registers_randomly();
  void vacate_registers();
};
