#pragma once

#include <boost/array.hpp>

using namespace boost;

typedef int Ordinate;
class Point {
public:
  array<Ordinate,2> x;

  Point(Ordinate x1, Ordinate x2);
  Point(const Point &that);
  ~Point();

  Point &operator=(const Point &that);
  Point &operator+=(const Point &that);
  bool operator==(const Point &that);
  Ordinate operator[](unsigned int i);
};

