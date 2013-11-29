#pragma once

#include <boost/array.hpp>

typedef int Ordinate;
class Point {
public:
  boost::array<Ordinate,2> x;

  Point(Ordinate x1, Ordinate x2);
  Point(const Point &that);
  ~Point();

  Point &operator=(const Point &that);
  Point &operator+=(const Point &that);
  bool operator==(const Point &that) const;
  Ordinate operator[](unsigned int i);
};

std::ostream& operator <<(std::ostream& os, const Point& point);
