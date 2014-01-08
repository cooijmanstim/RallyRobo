#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "mex.h"
#include "matrix.h"

#include "game.hpp"

/* for windows */
#ifndef snprintf
#define snprintf _snprintf
#endif

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
  if (nrhs != 1)
    mexErrMsgIdAndTxt("RR:BadArgument", "exactly one argument (a game structure) required");

  if (!mxIsStruct(prhs[0]))
    mexErrMsgIdAndTxt("RR:BadArgument", "argument should be a game structure");

  if (nlhs < 1)
    return;

  if (nlhs > 1)
    mexErrMsgIdAndTxt("RR:BadArgument", "only one output argument (a game structure) returned");

  Game game;
  game.from_mxArray(prhs[0]);
  game.perform_turn();
  plhs[0] = game.to_mxArray();
}
