#include <assert.h>
#include <vector>
#include <algorithm>
#include <boost/assign/list_of.hpp>

#include "util.hpp"
#include "card.hpp"
#include "game.hpp"

using namespace boost;
using namespace boost::assign;

Game::Game() : board(boost::extents[BoardWidth+2][BoardHeight+2][Feature::NFeatures]),
               deck(Card::generate_deck()) {
  using namespace Feature;
  // add a border of pits around the board.  this obviates the need to deal with bounds explicitly.
  // the coordinates for the interior of the board are now 1-based.
  for (size_t i = 0; i < BoardHeight+2; i++) {
    board[i][0][Pit] = 1;
    board[i][BoardHeight+1][Pit] = 1;
  }
  for (size_t j = 0; j < BoardWidth+2; j++) {
    board[0][j][Pit] = 1;
    board[BoardWidth+1][j][Pit] = 1;
  }

  // checkpoint labels are 1-based, put a dummy 0th checkpoint in our vector
  // to keep the correspondence
  checkpoints.push_back(Point(-1, -1));
}

Game::~Game() {
}

void Game::add_robot(Point initial_position, DirectionIndex initial_direction) {
  RobotIndex identity = robots.size();
  robots.push_back(shared_ptr<Robot>(new Robot(identity, initial_position, initial_direction)));
}

shared_ptr<Robot> Game::get_robot(RobotIndex i) const {
  return robots[i];
}

std::vector<shared_ptr<Robot> > Game::get_robots() const {
  return robots;
}

void Game::add_checkpoint(Point checkpoint) {
  checkpoints.push_back(checkpoint);
}

Game Game::example_game() {
  using namespace Feature;
  using namespace Direction;

  Game game;
  game.add_checkpoint(Point(12, 1));
  game.add_checkpoint(Point( 8, 9));
  game.add_checkpoint(Point( 2, 8));
  game.add_checkpoint(Point( 9, 5));

  game.add_robot(Point( 3,  1), East);
  game.add_robot(Point( 4, 11), North);
  game.add_robot(Point( 8,  1), North);
  game.add_robot(Point(11,  9), South);

  // set feature at points
  auto sfap = [&game](FeatureIndex fi, std::vector<Point> points) {
    std::for_each(points.begin(), points.end(), [&game, &fi] (Point x) {
        game.set_feature(Point(x[0], x[1]), fi);
      });
  };

  sfap(Pit,                list_of<Point>(5,8) (5,9) (7,3) (10,6));
  sfap(Repair,             list_of<Point>(1,2) (5,2) (3,5) (3,9) (8,5) (10,1));
  sfap(ConveyorNorth,      list_of<Point>(1,3) (2,3) (3,3) (4,7) (5,7));
  sfap(ConveyorEast,       list_of<Point>(4,3) (4,4) (4,5) (4,6) (6,7) (6,8) (6,9) (6,10) (6,11) (6,12));
  sfap(ConveyorWest,       list_of<Point>(6,1) (6,2) (6,3) (6,4) (7,5) (7,6) (7,7) (7,8) (7,9) (7,10) (7,11) (7,12));
  sfap(ConveyorSouth,      list_of<Point>(7,4));
  sfap(ConveyorTurningCcw, list_of<Point>(4,7) (7,4));
  sfap(ConveyorTurningCw,  list_of<Point>(6,7) (4,3) (6,4));
  sfap(WallEast,           list_of<Point>(5,4));
  sfap(WallNorth,          list_of<Point>(2,10) (5,4) (7,7) (10,3));
  sfap(WallWest,           list_of<Point>(1,4) (2,10) (3,7) (5,1) (9,11) (12,5));
  sfap(WallSouth,          list_of<Point>(1,6));

  return game;
}

bool Game::within_bounds(const Point &x) const {
  return
    0 <= x[0] && x[0] < BoardHeight+2 &&
    0 <= x[1] && x[1] < BoardWidth +2;
}

bool Game::has_feature(const Point &x, FeatureIndex i) const {
  return board[x[0]][x[1]][i];
}

void Game::set_feature(const Point &x, FeatureIndex i) {
  board[x[0]][x[1]][i] = 1;
}

bool Game::robot_can_move(Robot &robot, DirectionIndex dir) const {
  Point &a = robot.position;
  Point b(a);
  b += Direction::asPoints[dir];
  return !has_feature(a, Feature::Pit)
    && !has_feature(a, Feature::lateWall(dir))
    && !has_feature(b, Feature::earlyWall(dir));
}

/* Move the indicated robot in the direction 'dx', pushing other robots
 * if they are in the way.  Does not move if the move is obstructed or
 * would involve pushing a robot through an obstruction.
 * returns true if anything was moved.
 * Modifies game.
 */
bool Game::robot_move_maybe(Robot &robot, DirectionIndex dir) {
  if (!robot_can_move(robot, dir))
    return false;

  Point x(robot.position);
  Point dx(Direction::asPoints[dir]);
  x += dx;

  // it is assumed that pits are bottomless; occupied pits don't obstruct
  if (!has_feature(x, Feature::Pit)) {
    // if there is a robot at the destination, try to push it
    auto pushee_it = find_if(robots.begin(), robots.end(), [&x](shared_ptr<Robot>& pushee) {
        return !pushee->is_virtual && pushee->position == x;
      });
    if (pushee_it != robots.end() && !robot_move_maybe(**pushee_it, dir))
      return false;
  }

  // permission to land
  translate_robot(robot, dx);
  return true;
}

void Game::translate_robot(Robot &robot, const Point &dx) {
  robot.position += dx;
  if (has_feature(robot.position, Feature::Pit))
    robot.destroy();
}

void Game::process_card(Robot &robot, const Card &card) {
  if (card.translation == 0) {
    // rotation only
    robot.rotate(card.rotation);
  } else {
    // translation only, tile by tile
    DirectionIndex di = card.translation >= 0 ? robot.direction : Direction::opposite(robot.direction);
    for (int k = abs(card.translation); k >= 1; k--) {
      bool moved = robot_move_maybe(robot, di);
      if (!moved)
        break;
    }
  }
}

void Game::advance_conveyors() {
  // the project documentation guarantees that conveyor belt movement is never
  // obstructed. so we can move each robot in parallel without worrying about
  // what's on the tile it is moving to.
  std::for_each(robots.begin(), robots.end(), [this](shared_ptr<Robot>& robot) {
      if (robot->is_virtual || robot->is_waiting())
        return;

      using namespace Feature;
      
      Point dx(0, 0);
      std::for_each(std::begin(Direction::indices), std::end(Direction::indices),
               [this, robot, &dx](DirectionIndex dir) {
                 if (has_feature(robot->position, conveyorsByDirection[dir]))
                   dx = Direction::asPoints[dir];
               });
      translate_robot(*robot, dx);
      
      // this should only happen if the robot was moved, and it does.
      if (has_feature(robot->position, ConveyorTurningCcw)) {
        robot->rotate(1);
      } else if (has_feature(robot->position, ConveyorTurningCw)) {
        robot->rotate(-1);
      }
    });
}

void Game::fire_robot_lasers() {
  // many early exits if we handle it by searching for pairs of robots, one
  // having the other in its line of sight.
  std::for_each(robots.begin(), robots.end(), [this](shared_ptr<Robot>& shooter) {
      if (!shooter->can_shoot())
        return;

      FeatureIndex earlyWall = Feature::earlyWall(shooter->direction),
                    lateWall = Feature:: lateWall(shooter->direction);

      if (has_feature(shooter->position, lateWall))
        return;

      std::for_each(robots.begin(), robots.end(), [this, &shooter, earlyWall, lateWall](shared_ptr<Robot>& shootee) {
          if (shooter == shootee)
            return;

          if (!shootee->can_take_damage())
            return;

          if (has_feature(shootee->position, earlyWall))
            return;

          if (!Direction::in_line_of_sight(shooter->position, shooter->direction, shootee->position))
            return;

          // if there is a robot in the way, it will be the shootee in another iteration, so here it
          // acts only as an obstruction.
          if (std::any_of(robots.begin(), robots.end(), [&shooter, &shootee](shared_ptr<Robot>& obstructor) {
                return obstructor->obstructs()
                  && Direction::in_line_of_sight(   shooter->position, shooter->direction, obstructor->position)
                  && Direction::in_line_of_sight(obstructor->position, shooter->direction,    shootee->position);
              }))
            return;

          // trace line of sight to check for obstructing walls
          Point x(shooter->position);
          Point dx(Direction::asPoints[shooter->direction]);
          x += dx;
          while (x != shootee->position) {
            // this would imply a bug, probably in Direction::in_line_of_sight
            assert(within_bounds(x));
            if (has_feature(x, earlyWall)) return;
            if (has_feature(x,  lateWall)) return;
            x += dx;
          }

          shootee->take_damage();
        });
    });
}

void Game::remove_destroyed_robots() {
  std::for_each(robots.begin(), robots.end(), [this](shared_ptr<Robot>& robot) {
      if (robot->is_destroyed())
        robot->wait();
    });
}

bool Game::any_robot_obstructing(const Point &x, optional<shared_ptr<Robot> > exception) const {
  return std::any_of(robots.begin(), robots.end(), [this, &x, &exception](const shared_ptr<Robot>& robot) {
      if (exception && robot == *exception)
        return false;
      return robot->obstructs() && robot->position == x;
    });
}

void Game::respawn_waiting_robots() {
  std::for_each(robots.begin(), robots.end(), [this](shared_ptr<Robot>& robot) {
      if (robot->is_waiting())
        robot->respawn();
    });
}

void Game::devirtualize_robots() {
  std::for_each(robots.begin(), robots.end(), [this](shared_ptr<Robot>& robot) {
      if (robot->is_virtual) {
        if (!std::any_of(robots.begin(), robots.end(), [this, &robot](shared_ptr<Robot>& robot2) {
              return robot != robot2 && !robot2->is_waiting() && robot2->position == robot->position;
            }))
          robot->devirtualize();
      }
    });
}

void Game::promote_robots() {
  std::for_each(robots.begin(), robots.end(), [this](shared_ptr<Robot>& robot) {
      if (!robot->is_virtual && robot->is_active() && checkpoints[robot->next_checkpoint] == robot->position) {
        robot->respawn_position = robot->position;
        robot->respawn_direction = robot->direction;
        robot->next_checkpoint++;
        if (robot->next_checkpoint >= checkpoints.size()) {
          over = true;
          winner = robot->identity;
        }
      }
    });
}

void Game::repair_robots() {
  std::for_each(robots.begin(), robots.end(), [this](shared_ptr<Robot>& robot) {
      if (!robot->is_virtual && robot->is_active() && has_feature(robot->position, Feature::Repair)) {
        robot->repair();
      }
    });
}

// before calling this, make sure the registers are filled
// after calling this, make sure the registers are vacated
void Game::perform_turn() {
  // grab a working copy that we can sort according to card priority
  std::vector<shared_ptr<Robot> > robots(this->robots);

  for (size_t i = 0; i < NRegisters; i++) {
    std::sort(robots.begin(), robots.end(), [i](const shared_ptr<Robot>& a, const shared_ptr<Robot>& b) {
        return a->registers[i]->priority > b->registers[i]->priority;
      });

    std::for_each(robots.begin(), robots.end(), [this, i](const shared_ptr<Robot>& robot) {
        if (robot->is_active())
          process_card(*robot, *robot->registers[i]);
      });

    devirtualize_robots();
    advance_conveyors();
    fire_robot_lasers();
    promote_robots();
    repair_robots();
  }

  respawn_waiting_robots();
  remove_destroyed_robots();
  devirtualize_robots(); 
}

void Game::vacate_registers() {
  std::for_each(robots.begin(), robots.end(), [this](const shared_ptr<Robot>& robot) {
      Deck cards = robot->vacate_registers();
      deck.insert(cards.begin(), cards.end());
    });
}

void Game::fill_empty_registers_randomly() {
  std::for_each(robots.begin(), robots.end(), [this](const shared_ptr<Robot>& robot) {
      std::for_each(robot->registers.begin(), robot->registers.end(), [this](optional<Card>& card) {
          if (!card)
            card = Card::draw_card(deck);
        });
    });
}

