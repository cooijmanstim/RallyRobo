#include <vector>

#include "card.hpp"

using namespace std;

Card::Card(Priority priority, Translation translation, Rotation rotation)
  : priority(priority), translation(translation), rotation(rotation) {
}

Card::Card(const Card& that)
  : priority(that.priority), translation(that.translation), rotation(that.rotation) {
}

Card::~Card() {
}

Card& Card::operator=(const Card& that) {
  this->priority    = that.priority;
  this->translation = that.translation;
  this->rotation    = that.rotation;
  return *this;
}

vector<Card> Card::generate_deck() {
  vector<Card> cards;

  auto f = [&cards](Priority a, Priority b, Priority stride,
                    Translation translation, Rotation rotation) {
    for (Priority priority = a; priority <= b; priority += stride)
      cards.push_back(Card(priority, translation, rotation));
  };

  f( 10, 10,  60,  0,  2); // u-turn
  f( 70, 20, 410,  0,  1); // ccw rotation
  f( 80, 20, 420,  0, -1); // cw rotation
  f(430, 10, 480, -1,  0); // back up
  f(490, 10, 660,  1,  0); // one forward
  f(670, 10, 780,  2,  0); // two forward
  f(790, 10, 840,  3,  0); // three forward

  return cards;
}

const vector<Card> Card::deck = Card::generate_deck();

