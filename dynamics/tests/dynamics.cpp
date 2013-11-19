#define BOOST_TEST_MODULE dynamics test
#include <boost/test/included/unit_test.hpp>
#include <boost/algorithm/cxx11/all_of.hpp>

#include "point.hpp"
#include "robot.hpp"
#include "game.hpp"

using namespace boost;
using namespace boost::algorithm;

BOOST_AUTO_TEST_CASE(example_game) {
  Game game = Game::example_game();
  Point x = game.robot_position(2);
  BOOST_CHECK(!game.has_feature(x, Feature::Pit));
  BOOST_CHECK(!game.has_feature(x, Feature::WallEast));
  BOOST_CHECK(!game.has_feature(x, Feature::WallNorth));
  BOOST_CHECK(!game.has_feature(x, Feature::WallWest));
  BOOST_CHECK(!game.has_feature(x, Feature::WallSouth));
}

BOOST_AUTO_TEST_CASE(robot_can_leave) {
  Game game = Game::example_game();
  // the red robot
  RobotIndex irobot = 2;
  Point x = game.robot_position(irobot);
  // should be able to leave in any direction
  BOOST_CHECK(game.robot_can_leave(irobot, x, Direction::East));
  BOOST_CHECK(game.robot_can_leave(irobot, x, Direction::North));
  BOOST_CHECK(game.robot_can_leave(irobot, x, Direction::West));
  BOOST_CHECK(game.robot_can_leave(irobot, x, Direction::South));
}

BOOST_AUTO_TEST_CASE(robot_move_maybe) {
  Game game = Game::example_game();
  RobotIndex irobot = 2;
  game.set_robot_position(irobot, Point(5, 4));

  auto try_move = [&game, irobot](DirectionIndex dir, bool expected) {
    BOOST_CHECK(game.robot_move_maybe(irobot, dir) == expected);
  };

  using namespace Direction;

  try_move(North, false); // wall inside
  try_move(East,  false); // wall inside
  try_move(South, true);
  try_move(East,  true);
  try_move(North, true);
  try_move(West,  false); // wall outside
  try_move(North, true);
  try_move(West,  true);
  try_move(South, false); // wall outside
  try_move(North, true);
  try_move(West,  true);  // into pit
  try_move(East,  false);
  try_move(North, false);
  try_move(West,  false);
  try_move(South, false);
}
