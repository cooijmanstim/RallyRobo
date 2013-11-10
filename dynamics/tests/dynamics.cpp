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
