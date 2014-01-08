#include <boost/array.hpp>
#include <boost/assign/list_of.hpp>

using namespace boost;
using namespace boost::assign;

#include "point.hpp"

#include "matlab.hpp"

Point::Point(Ordinate x1, Ordinate x2) : x(list_of(x1)(x2)) {
}

Point::Point(const Point &that) : x(that.x) {
}

Point::~Point() {
}

Point Point::from_mxArray(const mxArray* m) {
  if (!mex::is_int(m))
    throw std::runtime_error("bad data type");
  if (mxGetNumberOfElements(m) != 2)
    throw std::runtime_error("bad shape");
  mex::int_t* d = (mex::int_t*)mxGetData(m);
  return Point(d[0], d[1]);
}

Ordinate& Point::operator[](std::size_t i) {
  return this->x[i];
}

const Ordinate& Point::operator[](std::size_t i) const {
  return this->x[i];
}

bool Point::operator==(const Point &that) const {
  return this->x[0] == that.x[0] && this->x[1] == that.x[1];
}

bool Point::operator!=(const Point &that) const {
  return this->x[0] != that.x[0] || this->x[1] != that.x[1];
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

std::ostream& operator <<(std::ostream& os, const Point& point) {
  os << "Point(" << point.x[0] << ", " << point.x[1] << ")";
  return os;
}
