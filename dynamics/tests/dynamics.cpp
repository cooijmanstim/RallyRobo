#define BOOST_TEST_MODULE dynamics test
#include <boost/test/included/unit_test.hpp>
#include <boost/algorithm/cxx11/all_of.hpp>
#include <boost/assign/list_of.hpp>

#include "util.hpp"
#include "point.hpp"
#include "direction.hpp"
#include "robot.hpp"
#include "game.hpp"

using namespace boost;
using namespace boost::algorithm;
using namespace boost::assign;

BOOST_AUTO_TEST_CASE(direction_rotate) {
  using namespace Direction;
  BOOST_CHECK(rotate(East, -1) == South);
  BOOST_CHECK(rotate(South, 2) == North);
}

BOOST_AUTO_TEST_CASE(in_line_of_sight) {
  using namespace Direction;
  BOOST_CHECK( Direction::in_line_of_sight(Point(0, 0), East,  Point( 0, 3)));
  BOOST_CHECK( Direction::in_line_of_sight(Point(0, 0), South, Point(-3, 0)));
  BOOST_CHECK(!Direction::in_line_of_sight(Point(0, 0), East,  Point(-3, 0)));
  BOOST_CHECK(!Direction::in_line_of_sight(Point(0, 0), South, Point(0, -3)));
}

BOOST_AUTO_TEST_CASE(early_late_wall) {
  using namespace Direction;
  using namespace Feature;
  BOOST_CHECK(earlyWall(East) == WallWest);
  BOOST_CHECK(lateWall(East) == WallEast);
}

BOOST_AUTO_TEST_CASE(example_game) {
  Game game = Game::example_game();
  Point x(8, 1);
  BOOST_CHECK(!game.has_feature(x, Feature::Pit));
  BOOST_CHECK(!game.has_feature(x, Feature::WallEast));
  BOOST_CHECK(!game.has_feature(x, Feature::WallNorth));
  BOOST_CHECK(!game.has_feature(x, Feature::WallWest));
  BOOST_CHECK(!game.has_feature(x, Feature::WallSouth));

  x = Point(5, 4);
  BOOST_CHECK(game.has_feature(x, Feature::WallNorth));
  BOOST_CHECK(game.has_feature(x, Feature::WallEast));
}

BOOST_AUTO_TEST_CASE(robot_can_move) {
  using namespace Direction;

  Game game = Game::example_game();

#define expect(dir, able) \
  BOOST_CHECK(game.robot_can_move(*robot, dir) == able);

  // the red robot
  shared_ptr<Robot> robot = game.get_robot(2);
  // should be able to move in any direction
  expect(East,  true);
  expect(North, true);
  expect(West,  true);
  expect(South, true);

  // but if we put it here
  robot->position = Point(5, 4);
  // it should only be able to move west or south
  expect(East,  false);
  expect(North, false);
  expect(West,  true);
  expect(South, true);

#undef expect
}

BOOST_AUTO_TEST_CASE(robot_move_maybe) {
  Game game = Game::example_game();
  shared_ptr<Robot> robot = game.get_robot(2);
  robot->position = Point(5, 4);

#define expect(dir, success) \
  BOOST_CHECK(game.robot_move_maybe(*robot, dir) == success);

  using namespace Direction;

  expect(North, false); // wall inside
  expect(East,  false); // wall inside
  expect(South, true);
  expect(East,  true);
  expect(North, true);
  expect(West,  false); // wall outside
  expect(North, true);
  expect(West,  true);
  expect(South, false); // wall outside
  expect(North, true);
  expect(West,  true);  // into pit
  expect(East,  false);
  expect(North, false);
  expect(West,  false);
  expect(South, false);

#undef expect
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

BOOST_AUTO_TEST_CASE(robot_rotate) {
  using namespace Direction;
  Robot robot(0, Point(0, 0), East);
  robot.rotate(-1);
  BOOST_CHECK(robot.direction == South);
  robot.rotate(2);
  BOOST_CHECK(robot.direction == North);
}

BOOST_AUTO_TEST_CASE(advance_conveyors) {
  Game game = Game::example_game();
  shared_ptr<Robot> robot = game.get_robot(0);

  using namespace Direction;

#define expect(x, dir) \
    BOOST_CHECK(robot->position  == x); \
    BOOST_CHECK(robot->direction == dir);

  // get on the conveyor belt
  game.process_card(*robot, Card(0, 2, 0));

  expect(Point(3, 3), East);
  game.advance_conveyors();
  expect(Point(4, 3), South);
  game.advance_conveyors();
  expect(Point(4, 4), South);
  game.advance_conveyors();
  expect(Point(4, 5), South);
  game.advance_conveyors();
  expect(Point(4, 6), South);
  BOOST_CHECK(game.has_feature(robot->position, Feature::ConveyorEast));
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

BOOST_AUTO_TEST_CASE(generate_deck) {
  Deck deck = Card::generate_deck();
  BOOST_CHECK(!deck.empty());
  BOOST_CHECK(deck.size() == 84);
}

BOOST_AUTO_TEST_CASE(perform_turn) {
  Game game = Game::example_game();

  /* get a random register assignment to use as a test case
  game.fill_empty_registers_randomly();
  std::vector<shared_ptr<Robot> > robots = game.get_robots();
  std::for_each(robots.begin(), robots.end(), [](shared_ptr<Robot> robot) {
      std::for_each(robot->registers.begin(), robot->registers.end(), [](optional<Card> card) {
          std::cout << *card << ", ";
        });
      std::cout << std::endl;
    }); //*/

  std::vector<shared_ptr<Robot> > robots = game.get_robots();
  robots[0]->registers = list_of<optional<Card>>(Card(180, 0,-1))(Card(630, 1, 0))(Card(310, 0, 1))(Card(350, 0, 1))(Card(640, 1, 0));
  robots[1]->registers = list_of<optional<Card>>(Card(440,-1, 0))(Card(100, 0,-1))(Card(570, 1, 0))(Card( 10, 0, 2))(Card(480,-1, 0));
  robots[2]->registers = list_of<optional<Card>>(Card(700, 2, 0))(Card(110, 0, 1))(Card(150, 0, 1))(Card(590, 1, 0))(Card(620, 1, 0));
  robots[3]->registers = list_of<optional<Card>>(Card( 60, 0, 2))(Card(230, 0, 1))(Card( 90, 0, 1))(Card(650, 1, 0))(Card(460,-1, 0));

  // let's see some destruction
  std::for_each(robots.begin(), robots.end(), [](shared_ptr<Robot> robot) {
      robot->damage = 8;
    });

  game.perform_turn();
  game.vacate_registers();

  using namespace Direction;
#define foo(robot, p, d, s, v) \
  BOOST_CHECK(robot->position == p); \
  BOOST_CHECK(robot->direction == d); \
  BOOST_CHECK(robot->state == s); \
  BOOST_CHECK(robot->is_virtual == v);

  foo(robots[0], Point( 2,  1), North, Robot::Waiting,   false);
  foo(robots[1], Point( 3, 13), West,  Robot::Destroyed, false);
  foo(robots[2], Point( 8,  1), South, Robot::Active,    false);
  foo(robots[3], Point(11,  9), South, Robot::Active,    false);
#undef foo
}
