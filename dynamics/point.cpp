#include <boost/array.hpp>
#include <boost/assign/list_of.hpp>

using namespace boost;
using namespace boost::assign;

#include "point.hpp"

Point::Point(Ordinate x1, Ordinate x2) : x(list_of(x1)(x2)) {
}

Point::Point(const Point &that) : x(that.x) {
}

Point::~Point() {
}

Point &Point::operator=(const Point &that) {
  this->x[0] = that.x[0];
  this->x[1] = that.x[1];
  return *this;
}

Point &Point::operator+=(const Point &that) {
  this->x[0] += that.x[0];
  this->x[1] += that.x[1];
  return *this;
}

bool Point::operator==(const Point &that) {
  return this->x[0] == that.x[0] && this->x[1] == that.x[1];
}

Ordinate Point::operator[](unsigned int i) {
  return this->x[i];
}
