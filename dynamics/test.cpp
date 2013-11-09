#include <boost/assign/list_of.hpp>
#include <algorithm>

#include "point.hpp"
#include "game.hpp"

using namespace boost::assign;
using namespace std;

class Test {
  Game game;

  void poop(FeatureIndex i, vector<Point> points) {
    for_each(points.begin(), points.end(), [this, &i] (Point x) {
        game.set_feature(x, i);
      });
  }

  Test() : game(list_of<Robot>(Point(3, 1), Direction::North, 0),
                list_of<Point>(12, 1) (8, 9) (2, 8) (9, 5))
  {
    poop(Feature::Pit, list_of<Point>(8, 5) (9, 5) (3, 7) (6, 10));
    poop(Feature::Repair, list_of<Point>(2,1) (2,5) (5,3) (9,3) (5,8) (1,10));
    poop(Feature::ConveyorNorth, list_of<Point>(3,1) (3,2) (3,3) (7,4) (7,5));
    poop(Feature::ConveyorEast, list_of<Point>(3,4) (4,4) (5,4) (6,4) (7,6) (8,6) (9,6) (10,6) (11,6) (12,6));
    poop(Feature::ConveyorWest, list_of<Point>(1,6) (2,6) (3,6) (4,6) (5,7) (6,7) (7,7) (8,7) (9,7) (10,7) (11,7) (12,7));
    poop(Feature::ConveyorSouth, list_of<Point>(4,7));
    poop(Feature::ConveyorTurningCcw, list_of<Point>(7,4) (4,7));
    poop(Feature::ConveyorTurningCw, list_of<Point>(7,6) (3,4) (4,6));
    poop(Feature::WallEast, list_of<Point>(4,5));
    poop(Feature::WallNorth, list_of<Point>(10,2) (4,5) (7,7) (3,10));
    poop(Feature::WallWest, list_of<Point>(4,1) (10,2) (7,3) (1,5) (11,9) (5,12));
    poop(Feature::WallSouth, list_of<Point>(6,1));
  }
};
