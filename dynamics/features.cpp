#include "features.hpp"

namespace Feature {
  FeatureIndex features[] = {
    Pit, Repair,
    WallEast, WallNorth, WallWest, WallSouth,
    ConveyorEast, ConveyorNorth, ConveyorWest, ConveyorSouth,
    ConveyorTurningCw, ConveyorTurningCcw,
  };

  FeatureIndex wallsByDirection[] = {
    WallEast, WallNorth, WallWest, WallSouth,
  };

  FeatureIndex conveyorsByDirection[] = {
    ConveyorEast, ConveyorNorth, ConveyorWest, ConveyorSouth,
  };

  FeatureIndex earlyWall(DirectionIndex dir) { return wallsByDirection[Direction::opposite(dir)]; }
  FeatureIndex  lateWall(DirectionIndex dir) { return wallsByDirection[dir]; }
}

