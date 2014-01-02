#pragma once

#include <boost/array.hpp>

typedef int Ordinate;
class Point {
public:
  boost::array<Ordinate,2> x;

  Point(Ordinate x1, Ordinate x2);
  Point(const Point &that);
  ~Point();

  const Ordinate& operator[](std::size_t i) const;
  Ordinate& operator[](std::size_t i);

  bool operator==(const Point &that) const;
  bool operator!=(const Point &that) const;

  Point &operator=(const Point &that);
  Point &operator+=(const Point &that);
};

std::ostream& operator <<(std::ostream& os, const Point& point);
