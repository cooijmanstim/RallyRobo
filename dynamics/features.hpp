#pragma once

#include "direction.hpp"

namespace Feature {
#define FEATURES Pit, Repair, WallEast, WallNorth, WallWest, WallSouth, \
                 ConveyorEast, ConveyorNorth, ConveyorWest, ConveyorSouth, \
                 ConveyorTurningCw, ConveyorTurningCcw
  enum FeatureIndex {
    FEATURES,
    NFeatures,
  };

  FeatureIndex features[] = {
    FEATURES
  };
#undef FEATURES

  FeatureIndex wallsByDirection[] = {
    WallEast, WallNorth, WallWest, WallSouth,
  };

  FeatureIndex conveyorsByDirection[] = {
    ConveyorEast, ConveyorNorth, ConveyorWest, ConveyorSouth,
  };

  FeatureIndex earlyWall(DirectionIndex dir) { return wallsByDirection[dir]; }
  FeatureIndex  lateWall(DirectionIndex dir) { return wallsByDirection[Direction::opposite(dir)]; }
}
typedef Feature::FeatureIndex FeatureIndex;

