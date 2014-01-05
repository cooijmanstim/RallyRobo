#pragma once

#include "prettyprint.hpp"

template<typename T, std::size_t N>
std::ostream& operator <<(std::ostream& os, const boost::array<T, N>& a) {
  os << pretty_print::array_wrapper_n<T>(a.data(), N);
  return os;
}
