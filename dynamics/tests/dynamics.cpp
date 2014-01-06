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

BOOST_AUTO_TEST_CASE(push_many) {
  Game game = Game::example_game();
  std::vector<shared_ptr<Robot> > robots = game.get_robots();

  using namespace Direction;

  robots[0]->position = Point( 9, 9);
  robots[0]->direction = North;
  robots[2]->position = Point(10, 9);
  robots[2]->direction = West;
  robots[3]->position = Point(11, 9);
  robots[3]->direction = South;

  robots[2]->destroy();

  game.process_card(*robots[3], Card(0, 1, 0));

  BOOST_CHECK_EQUAL(robots[0]->position, Point( 8, 9));
  BOOST_CHECK_EQUAL(robots[2]->position, Point( 9, 9));
  BOOST_CHECK_EQUAL(robots[3]->position, Point(10, 9));
}

BOOST_AUTO_TEST_CASE(push_many_into_pit) {
  Game game = Game::example_game();
  std::vector<shared_ptr<Robot> > robots = game.get_robots();

  using namespace Direction;

  robots[0]->position = Point(10, 8);
  robots[0]->direction = West;
  robots[1]->position = Point(10, 7);
  robots[1]->direction = East;
  robots[2]->position = Point(10, 6);
  robots[2]->direction = North;
  robots[2]->destroy();

  game.process_card(*robots[0], Card(0, 3, 0));

  BOOST_CHECK_EQUAL(robots[0]->position, Point(10, 6));
  BOOST_CHECK_EQUAL(robots[1]->position, Point(10, 6));
  BOOST_CHECK_EQUAL(robots[2]->position, Point(10, 6));

  BOOST_CHECK(robots[0]->is_destroyed());
  BOOST_CHECK(robots[1]->is_destroyed());
  BOOST_CHECK(robots[2]->is_destroyed());
}

BOOST_AUTO_TEST_CASE(fire_robot_lasers) {
  Game game = Game::example_game();
  std::vector<shared_ptr<Robot> > robots = game.get_robots();

  using namespace Direction;

  robots[0]->position  = Point( 9, 9);
  robots[0]->direction = North;
  robots[1]->position  = Point(10, 6);
  robots[1]->direction = East;
  robots[2]->position  = Point(10, 9);
  robots[2]->direction = West;
  robots[3]->position  = Point(11, 9);
  robots[3]->direction = South;

  robots[1]->destroy();

  game.fire_robot_lasers();

  BOOST_CHECK_EQUAL(robots[0]->damage, 0);
  BOOST_CHECK_EQUAL(robots[1]->damage, 0);
  BOOST_CHECK_EQUAL(robots[2]->damage, 2);
  BOOST_CHECK_EQUAL(robots[3]->damage, 0);
}

BOOST_AUTO_TEST_CASE(perform_turn) {
  Game game = Game::example_game();

  std::vector<shared_ptr<Robot> > robots = game.get_robots();

  using namespace Direction;
#define check_robot(robot, p, d, c) \
  BOOST_CHECK_EQUAL(robot->position, p); \
  BOOST_CHECK_EQUAL(robot->direction, d); \
  BOOST_CHECK_EQUAL(robot->next_checkpoint, c);

  // NOTE: we don't interact with the game deck, so don't bother checking its integrity

  robots[0]->registers = list_of<optional<Card>>(Card(110, 0, 1))(Card(630, 1, 0))(Card(780, 2, 0))(Card(350, 0, 1))(Card(640, 1, 0));
  robots[1]->registers = list_of<optional<Card>>(Card(810, 3, 0))(Card(100, 0,-1))(Card(430,-1, 0))(Card(450,-1, 0))(Card(120, 0,-1));
  robots[2]->registers = list_of<optional<Card>>(Card(700, 2, 0))(Card(490, 1, 0))(Card(440,-1, 0))(Card(670, 2, 0))(Card(460,-1, 0));
  robots[3]->registers = list_of<optional<Card>>(Card( 80, 0,-1))(Card(680, 2, 0))(Card(830, 3, 0))(Card(460,-1, 0))(Card(470,-1, 0));

  game.perform_turn();

  BOOST_CHECK(robots[0]->is_waiting());

  check_robot(robots[1], Point( 7,  4), East,  1);
  check_robot(robots[2], Point(11,  1), North, 2);
  check_robot(robots[3], Point(11,  6), West,  1);


  robots[0]->registers = list_of<optional<Card>>(Card(110, 0, 1))(Card(630, 1, 0))(Card(770, 2, 0))(Card(350, 0, 1))(Card(640, 1, 0));
  robots[1]->registers = list_of<optional<Card>>(Card(490, 1, 0))(Card(800, 3, 0))(Card(780, 2, 0))(Card( 70, 0, 1))(Card(430,-1, 0));
  robots[2]->registers = list_of<optional<Card>>(Card(100, 0,-1))(Card(840, 3, 0))(Card(680, 2, 0))(Card(120, 0,-1))(Card(830, 3, 0));
  robots[3]->registers = list_of<optional<Card>>(Card(670, 2, 0))(Card(500, 1, 0))(Card( 10, 0, 2))(Card(460,-1, 0))(Card(470,-1, 0));

  game.perform_turn();

  BOOST_CHECK(robots[0]->is_active());
  BOOST_CHECK(robots[3]->is_waiting());

  check_robot(robots[0], Point( 3,  1), East,  1);
  check_robot(robots[1], Point(12,  4), West,  1);
  check_robot(robots[2], Point( 8,  5), South, 2);


  robots[0]->registers = list_of<optional<Card>>(Card(670, 2, 0))(Card( 70, 0, 1))(Card(790, 3, 0))(Card(170, 0, 1))(Card(190, 0, 2));
  robots[1]->registers = list_of<optional<Card>>(Card(820, 3, 0))(Card( 90, 0, 1))(Card(680, 2, 0))(Card(110, 0, 1))(Card(490, 1, 0));
  robots[2]->registers = list_of<optional<Card>>(Card(710, 2, 0))(Card(130, 0, 1))(Card(720, 2, 0))(Card(150, 0, 1))(Card(730, 2, 0));
  robots[3]->registers = list_of<optional<Card>>(Card(670, 2, 0))(Card(500, 1, 0))(Card( 10, 0, 2))(Card(460,-1, 0))(Card(470,-1, 0));

  game.perform_turn();

  BOOST_CHECK(robots[3]->is_active());

  check_robot(robots[0], Point( 6,  8), West,  1);
  check_robot(robots[1], Point(10,  2), East,  2);
  check_robot(robots[2], Point( 8,  9), North, 3);
  check_robot(robots[3], Point(11,  9), South, 1);


  robots[0]->registers = list_of<optional<Card>>(Card( 90, 0,-1))(Card(680, 2, 0))(Card(590, 1, 0))(Card(440,-1, 0))(Card( 90, 0, 1));
  robots[1]->registers = list_of<optional<Card>>(Card(550, 1, 0))(Card(560, 1, 0))(Card(570, 1, 0))(Card(580, 1, 0))(Card(840, 3, 0));
  robots[2]->registers = list_of<optional<Card>>(Card(670, 2, 0))(Card(500, 1, 0))(Card( 70, 0, 1))(Card(530, 1, 0))(Card(540, 1, 0));
  robots[3]->registers = list_of<optional<Card>>(Card(490, 1, 0))(Card(430,-1, 0))(Card(510, 1, 0))(Card(520, 1, 0))(Card( 80, 0,-1));

  game.perform_turn();

  BOOST_CHECK(robots[1]->is_waiting());
  BOOST_CHECK(robots[2]->is_waiting());

  check_robot(robots[0], Point( 7,  7), West, 1);
  check_robot(robots[3], Point(10,  9), West, 1);


  robots[0]->registers = list_of<optional<Card>>(Card( 80, 0,-1))(Card(490, 1, 0))(Card(100, 0,-1))(Card(790, 3, 0))(Card(120, 0,-1));
  robots[1]->registers = list_of<optional<Card>>(Card(550, 1, 0))(Card(560, 1, 0))(Card(570, 1, 0))(Card(580, 1, 0))(Card(840, 3, 0));
  robots[2]->registers = list_of<optional<Card>>(Card(670, 2, 0))(Card(500, 1, 0))(Card( 70, 0, 1))(Card(530, 1, 0))(Card(540, 1, 0));
  robots[3]->registers = list_of<optional<Card>>(Card(500, 1, 0))(Card(440,-1, 0))(Card(680, 2, 0))(Card(450,-1, 0))(Card(460,-1, 0));

  game.perform_turn();

  BOOST_CHECK(robots[1]->is_active());
  BOOST_CHECK(robots[2]->is_active());

  check_robot(robots[0], Point( 8,  9), South, 1);
  check_robot(robots[1], Point(12,  1), West,  2);
  check_robot(robots[2], Point( 8,  9), North, 3);
  check_robot(robots[3], Point(10,  9), West,  1);

  BOOST_CHECK( robots[2]->is_virtual);
  BOOST_CHECK(!robots[0]->is_virtual);
#undef check_robot
}
