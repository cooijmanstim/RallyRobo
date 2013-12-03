#pragma once

#include <vector>

typedef unsigned int Priority;
typedef short Translation;
typedef short Rotation;

class Card {
public:
  static std::vector<Card> generate_deck();
  static const std::vector<Card> deck;

  Priority priority;
  Translation translation; // number of steps in the direction faced
  Rotation rotation; // number of counterclockwise quarter rotations

  Card(Priority priority, Translation translation, Rotation rotation);
  Card(const Card& that);
  ~Card();
};
