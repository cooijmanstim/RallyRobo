#pragma once

#include "mex.h"
#include "matrix.h"

namespace mex {
  typedef  int16_T  int_t;
  typedef uint16_T uint_t;
  typedef     byte bool_t;

  mxClassID  int_t_classid = mxINT16_CLASS;
  mxClassID uint_t_classid = mxINT16_CLASS;
  mxClassID int_t_classid = mxINT16_CLASS;
  
  bool is_int (const mxArray *m) { return mxGetClassId(m) ==  int_t_classid; }
  bool is_uint(const mxArray *m) { return mxGetClassId(m) == uint_t_classid; }
  bool is_bool(const mxArray *m) { return mxIsLogical(m); }

  int_t int_from_mxArray(const mxArray *m) {
    if (!is_int(m))
      throw std::exception("expected int_t array");
    if (mxGetNumberOfElements(m) != 1)
      throw std::exception("expected scalar");
    return *(int_t*)mxGetData(m);
  }

  uint_t uint_from_mxArray(const mxArray *m) {
    if (!is_uint(m))
      throw std::exception("expected int_t array");
    if (mxGetNumberOfElements(m) != 1)
      throw std::exception("expected scalar");
    return *(uint_t*)mxGetData(m);
  }

  bool_t bool_from_mxArray(const mxArray *m) {
    if (!is_bool(m))
      throw std::exception("expected logical array");
    if (mxGetNumberOfElements(m) != 1)
      throw std::exception("expected scalar");
    return *(bool_t*)mxGetLogicals(m);
  }

  mxArray* uint_to_mxArray(uint_t i) {
    mxArray* m = mxCreateNumericMatrix(1, 1, uint_t_classid, mxREAL);
    mxGetData(m)[0] = i;
    return m;
  }

  mxArray* bool_to_mxArray(bool_t b) {
    return mxCreateLogicalScalar(b);
  }
}
