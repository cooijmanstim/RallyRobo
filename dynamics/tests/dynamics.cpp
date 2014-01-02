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
  Point x(8, 1);
  BOOST_CHECK(!game.has_feature(x, Feature::Pit));
  BOOST_CHECK(!game.has_feature(x, Feature::WallEast));
  BOOST_CHECK(!game.has_feature(x, Feature::WallNorth));
  BOOST_CHECK(!game.has_feature(x, Feature::WallWest));
  BOOST_CHECK(!game.has_feature(x, Feature::WallSouth));
}

BOOST_AUTO_TEST_CASE(robot_can_leave) {
  Game game = Game::example_game();
  // the red robot
  shared_ptr<Robot> robot = game.get_robot(2);
  // should be able to move in any direction
  BOOST_CHECK(game.robot_can_move(*robot, Direction::East));
  BOOST_CHECK(game.robot_can_move(*robot, Direction::North));
  BOOST_CHECK(game.robot_can_move(*robot, Direction::West));
  BOOST_CHECK(game.robot_can_move(*robot, Direction::South));
}

BOOST_AUTO_TEST_CASE(robot_move_maybe) {
  Game game = Game::example_game();
  shared_ptr<Robot> robot = game.get_robot(2);
  robot->position = Point(5, 4);

  auto try_move = [&game, &robot](DirectionIndex dir, bool expected) {
    BOOST_CHECK(game.robot_move_maybe(*robot, dir) == expected);
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

BOOST_AUTO_TEST_CASE(process_card) {
  Game game = Game::example_game();
  shared_ptr<Robot> robot = game.get_robot(0),
                    pushed_robot = game.get_robot(1);

  using namespace Direction;

  BOOST_CHECK(robot->position == Point(3, 1));
  BOOST_CHECK(robot->direction == East);

  BOOST_CHECK(pushed_robot->position == Point(4, 11));
  
  auto after_card = [&robot, &game](Card card, Point position, DirectionIndex direction) {
    game.process_card(*robot, card);
    BOOST_CHECK(robot->position  == position);
    BOOST_CHECK(robot->direction == direction);
  };

  after_card(Card(0,  2,  0), Point(3,  3), East);
  after_card(Card(0,  2,  0), Point(3,  5), East);
  after_card(Card(0,  2,  0), Point(3,  6), East); // ran into a wall
  after_card(Card(0,  0,  1), Point(3,  6), North);
  after_card(Card(0,  2,  0), Point(5,  6), North);
  after_card(Card(0, -1,  0), Point(4,  6), North);
  after_card(Card(0,  0, -1), Point(4,  6), East);
  after_card(Card(0,  3,  0), Point(4,  9), East);
  after_card(Card(0,  3,  0), Point(4, 12), East); // push other robot off the board
  BOOST_CHECK(pushed_robot->position == Point(4, 13));
  after_card(Card(0,  0,  2), Point(4, 12), West);
  after_card(Card(0,  3,  0), Point(4,  9), West);
  after_card(Card(0,  0, -1), Point(4,  9), North);
  after_card(Card(0,  3,  0), Point(5,  9), North); // fell into a pit

  // can't leave pit in any direction
  for (int i = 0; i < 4; i++) {
    game.process_card(*robot, Card(0, 0, 1));
    game.process_card(*robot, Card(0, 1, 0));
    BOOST_CHECK(robot->position == Point(5, 9));
  }
}

BOOST_AUTO_TEST_CASE(direction_rotate) {
  using namespace Direction;
  BOOST_CHECK(rotate(East, -1) == South);
  BOOST_CHECK(rotate(South, 2) == North);
}

BOOST_AUTO_TEST_CASE(robot_rotate) {
  using namespace Direction;
  Robot robot(Point(0, 0), East, 0);
  robot.rotate(-1);
  BOOST_CHECK(robot.direction == South);
  robot.rotate(2);
  BOOST_CHECK(robot.direction == North);
}

BOOST_AUTO_TEST_CASE(advance_conveyors) {
  Game game = Game::example_game();
  RobotIndex irobot = 0;

  using namespace Direction;

#define expect(x, dir) \
    BOOST_CHECK(game.robot_position(irobot) == x); \
    BOOST_CHECK(game.robot_direction(irobot) == dir);

  // get on the conveyor belt
  game.process_card(irobot, Card(0, 2, 0));

  expect(Point(3, 3), East);
  game.advance_conveyors();
  expect(Point(4, 3), South);
  game.advance_conveyors();
  expect(Point(4, 4), South);
  game.advance_conveyors();
  expect(Point(4, 5), South);
  game.advance_conveyors();
  expect(Point(4, 6), South);
  BOOST_CHECK(game.has_feature(game.robot_position(irobot), Feature::ConveyorEast));
  game.advance_conveyors();
  expect(Point(4, 7), East);
  game.advance_conveyors();
  game.advance_conveyors();
  expect(Point(6, 7), South);
  game.advance_conveyors();
  game.advance_conveyors();
  game.advance_conveyors();
  game.advance_conveyors();
  game.advance_conveyors();
  expect(Point(6, 12), South);

  // move off the board (effectively into pit)
  game.advance_conveyors();
  expect(Point(6, 13), South);
  game.advance_conveyors();
  expect(Point(6, 13), South);
#undef expect
}
