#pragma once

#include <boost/unordered_set.hpp>
#include <boost/functional/hash.hpp>

typedef unsigned int Priority;
typedef short Translation;
typedef short Rotation;

class Card;

std::size_t hash_value(const Card& card);

typedef boost::unordered_set<Card> Deck;

class Card {
public:
  static Deck generate_deck();
  static Card draw_card(Deck& deck);
  static Deck draw_cards(size_t n, Deck& deck);

  Priority priority;
  Translation translation; // number of steps in the direction faced
  Rotation rotation; // number of counterclockwise quarter rotations

  Card(Priority priority, Translation translation, Rotation rotation);
  Card(const Card& that);
  ~Card();

  bool operator==(const Card& that) const;
};

std::ostream& operator <<(std::ostream& os, const Card& card);

