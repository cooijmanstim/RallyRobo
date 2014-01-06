#include <vector>

#include <boost/functional/hash.hpp>

#include <boost/random/mersenne_twister.hpp>
#include <boost/random/uniform_int_distribution.hpp>

// TODO: move this somewhere sensible
boost::mt19937 generator;

#include "card.hpp"

Card::Card(Priority priority, Translation translation, Rotation rotation)
  : priority(priority), translation(translation), rotation(rotation) {
}

Card::Card(const Card& that)
  : priority(that.priority), translation(that.translation), rotation(that.rotation) {
}

Card::~Card() {
}

bool Card::operator==(const Card& that) const {
  return this->priority    == that.priority    &&
         this->translation == that.translation &&
         this->rotation    == that.rotation;
}

Deck Card::generate_deck() {
  Deck deck;

  auto f = [&deck](Priority a, Priority stride, Priority b,
                   Translation translation, Rotation rotation) {
    for (Priority priority = a; priority <= b; priority += stride)
      deck.emplace(priority, translation, rotation);
  };

  f( 10, 10,  60,  0,  2); // u-turn
  f( 70, 20, 410,  0,  1); // ccw rotation
  f( 80, 20, 420,  0, -1); // cw rotation
  f(430, 10, 480, -1,  0); // back up
  f(490, 10, 660,  1,  0); // one forward
  f(670, 10, 780,  2,  0); // two forward
  f(790, 10, 840,  3,  0); // three forward

  return deck;
}

Card Card::draw_card(Deck& deck) {
  assert(!deck.empty());
  boost::random::uniform_int_distribution<> dist(0, deck.size() - 1);
  size_t i = dist(generator);
  auto it = deck.begin();
  advance(it, i);
  Card card = *it;
  deck.erase(card);
  return card;
}

// XXX: this could be sped up
Deck Card::draw_cards(size_t n, Deck& deck) {
  Deck cards;
  for (size_t i = 0; i < n; i++)
    cards.insert(draw_card(deck));
  return cards;
}

std::ostream& operator <<(std::ostream& os, const Card& card) {
  os << "Card(" << card.priority << ", " << card.translation << ", " << card.rotation << ")";
  return os;
}

std::size_t hash_value(const Card& card) {
  std::size_t hash = 0;
  boost::hash_combine(hash, card.priority);
  boost::hash_combine(hash, card.translation);
  boost::hash_combine(hash, card.rotation);
  return hash;
}
