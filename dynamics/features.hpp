#pragma once

#include "direction.hpp"

namespace Feature {
  enum FeatureIndex {
    Pit, Repair,
    WallEast, WallNorth, WallWest, WallSouth,
    ConveyorEast, ConveyorNorth, ConveyorWest, ConveyorSouth,
    ConveyorTurningCw, ConveyorTurningCcw,
    NFeatures,
  };

  extern FeatureIndex features[NFeatures];
  extern FeatureIndex wallsByDirection[Direction::NDirections];
  extern FeatureIndex conveyorsByDirection[Direction::NDirections];

  FeatureIndex earlyWall(DirectionIndex dir);
  FeatureIndex  lateWall(DirectionIndex dir);
}

typedef Feature::FeatureIndex FeatureIndex;

