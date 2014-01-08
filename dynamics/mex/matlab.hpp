#pragma once

#include "mex.h"
#include "matrix.h"

#include "../game.hpp"

namespace mex {
  typedef  int16_T  int_t;
  typedef uint16_T uint_t;
  typedef     byte bool_t;

  mxClassID  int_t_classid = mxINT16_CLASS;
  mxClassID uint_t_classid = mxINT16_CLASS;
  
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


  void game_from_mxArray(mxArray* mgame, Game& cgame) {
    mxArray* mboard       = mxGetField(mgame, 0, "board"),
             mcheckpoints = mxGetField(mgame, 0, "checkpoints"),
             mrobots      = mxGetField(mgame, 0, "robots");
  
    if (!mboard || !checkpoints || !mrobots)
      mexErrMsgIdAndTxt("RR:BadArgument", format("argument is not a game structure"));
  
    {
      if (!is_bool(mboard))
        mexErrMsgIdAndTxt("RR:BadArgument", "board should be a logical array");
      
      mxArray* mdimensions = mxGetDimensions(mboard);
      if (mxGetNumberOfDimensions(mboard) != 3 ||
          mdimensions[0] != BoardHeight ||
          mdimensions[1] != BoardWidth)
        mexErrMsgIdAndTxt("RR:BadArgument", format("size(board) should be [%1% %2% %3%]") % BoardHeight % BoardWidth % Feature::NFeatures);
  
      bool_t* dboard = mxGetLogicals(mboard);
      mwSize nsubs = 3;
      mwIndex subs = {0, 0, 0};
      for (subs[0] = 0; subs[0] < BoardHeight; subs[0]++)
        for (subs[1] = 0; subs[1] < BoardWidth; subs[1]++)
          for (subs[2] = 0; subs[2] < Feature::Nfeatures; subs[2]++)
            cgame.board[subs[0]+1][subs[1]+1][subs[2]] = dboard[mxCalcSingleSubscript(mboard, nsubs, subs)];
    }
  
    {
      mxArray* mdimensions = mxGetDimensions(mcheckpoints);
      if (mxGetNumberOfDimensions(mcheckpoints) != 2 ||
          mdimensions[1] != 2)
        mexErrMsgIdAndTxt("RR:BadArgument", "size(checkpoints) should be [n 2]");
  
      if (!is_int(mcheckpoints))
        mexErrMsgIdAndTxt("RR:BadArgument", "checkpoints should be int_t");
  
      int_t* dcheckpoints = (int_t*)mxGetData(mcheckpoints);
      mwSize nsubs = 2;
      mwIndex subs = {0, 0};
      Point x;
      for (subs[0] = 0; subs[0] < mdimensions[0]; subs[0]++) {
        for (subs[1] = 0; subs[1] < 2; subs[1]++)
          x[subs[1]] = dcheckpoints[mxCalcSingleSubscript(mcheckpoints, nsubs, subs)];
        cgame.add_checkpoint(x);
      }
    }
  
    {
      if (!mxIsStruct(mrobots))
        mexErrMsgIdAndTxt("RR:BadArgument", "state.robots should be a structure array");
  
      size_t n = mxGetNumberOfElements(mrobots);
      for (size_t i = 0; i < n; i++)
        cgame.add_robot(robot_from_mxStruct(mrobots, i));
    }
  
    return cgame;
  }
  
  mxArray* game_to_mxArray(const Game& cgame) {
    mxArray* mboard, mcheckpoints, mrobots;
  
    {
      mwSize ndim = 3;
      mwSize dims[] = {BoardHeight, BoardWidth, Feature::NFeatures};
      mboard = mxCreateLogicalArray(ndim, dims);
      bool_t* dboard = mxGetLogicals(mboard);
      mwSize nsubs = 3;
      mwIndex subs = {0, 0, 0};
      for (subs[0] = 0; subs[0] < dims[0]; subs[0]++)
        for (subs[1] = 0; subs[1] < dims[1]; subs[1]++)
          for (subs[2] = 0; subs[2] < dims[2]; subs[2]++)
            dboard[mxCalcSingleSubscript(mboard, nsubs, subs)] = cgame.board[subs[0]+1][subs[1]+1][subs[2]];
    }
  
    {
      mcheckpoints = mxCreateNumericMatrix(cgame.checkpoints.size(), 2, int_t_classid, mxREAL);
      dcheckpoints = (int_t*)mxGetData(mcheckpoints);
      mwSize nsubs = 2;
      mwIndex subs = {0, 0};
      for (subs[0] = 0; subs[0] < cgame.checkpoints.size(); subs[0]++)
        for (subs[1] = 0; subs[1] < 2; subs[1]++)
          dcheckpoints[mxCalcSingleSubscript(mcheckpoints, nsubs, subs)] = cgame.checkpoints[i].x[subs[1]];
    }
  
    {
      char* pfft[] = {"position", "direction",
                      "respawn_position", "respawn_direction",
                      "next_checkpoint",
                      "state", "is_virtual", "registers"};
      mrobots = mxCreateStructMatrix(1, 1, 3, pfft);
  
      for (size_t i = 0; i < cgame.robots.size(); i++)
        robots[i].into_mxStruct(mrobots, i);
    }
  
    char* fieldnames[] = {"board", "checkpoints", "robots"};
    mxArray* mgame = mxCreateStructMatrix(1, 1, 3, fieldnames);
    mxSetField(mgame, 0, "board",       mboard);
    mxSetField(mgame, 0, "checkpoints", mcheckpoints);
    mxSetField(mgame, 0, "robots",      mrobots);
    return mgame;
  }
  
  Robot robot_from_mxStruct(mxArray* mrobots, RobotIndex i, Robot& robot) {
    Robot robot;
    robot.identity = i;
  
    auto registers_from_mxArray = [](mxArray* mregisters) {
      if (!mxIsStruct(mregisters))
        throw std::runtime_error("expected a structure array");
  
      if (mxGetNumberOfElements(mregisters) != NRegisters)
        throw std::runtime_error(format("expected %1% registers") % NRegisters);
  
      boost::array<boost::optional<Card>, NRegisters> registers;
      for (size_t i = 0; i < NRegisters; i++) {
        mxArray* mpriority = mxGetField(mregisters, i, "priority");
        if (!mpriority)
          continue;
  
        mxArray* mtranslation = mxGetField(mregisters, i, "translation");
        mxArray* mrotation    = mxGetField(mregisters, i, "rotation");
        registers[i] = Card(int_from_mxArray(mpriority),
                            int_from_mxArray(mtranslation),
                            int_from_mxArray(mrotation));
      }
      return registers;
    };
  
    #define kak(key, processor)                                   \
      try {                                                       \
        robot. ## key = processor(mxGetField(mrobots, i, #key));  \
      } catch (std::exception e) {                                \
        mexErrMsgIdAndTxt("RR:BadArgument", format("failed to process state.robots(%1%)." #key ": %2%") % i % e); \
      }
  
    kak(position, point_from_mxArray);
    kak(direction, uint_from_mxArray);
    kak(respawn_position, point_from_mxArray);
    kak(respawn_direction, uint_from_mxArray);
    kak(next_checkpoint, uint_from_mxArray);
    kak(state, uint_from_mxArray);
    kak(is_virtual, bool_from_mxArray);
    kak(registers, registers_from_mxArray);
  
    #undef kak
  
    return robot;
  }
  
  void robot_into_mxStruct(mxArray* mrobots, RobotIndex i, const Robot& robot) {
    auto registers_to_mxArray = [](boost::array<boost::optional<Card>, NRegisters>& registers) {
      char *augh[] = {"priority", "translation", "rotation"};
      mxArray* mregisters = mxCreateStructArray(NRegisters, 1, 3, augh);
      
      for (int i = 0; i < NRegisters; i++) {
        if (!registers[i])
          continue;
  
        mxSetField(mregisters, i, "priority",    int_to_mxArray(registers[i]->priority));
        mxSetField(mregisters, i, "translation", int_to_mxArray(registers[i]->translation));
        mxSetField(mregisters, i, "rotation",    int_to_mxArray(registers[i]->rotation));
      }
    };
  
    #define kak(key, processor) mxSetField(mrobots, i, #key, processor(robot.key));
    kak(position, point_to_mxArray);
    kak(direction, uint_to_mxArray);
    kak(respawn_position, point_to_mxArray);
    kak(respawn_direction, uint_to_mxArray);
    kak(next_checkpoint, uint_to_mxArray);
    kak(state, uint_to_mxArray);
    kak(is_virtual, bool_to_mxArray);
    kak(registers, registers_to_mxArray);
    #undef kak
  }
  
  Point point_from_mxArray(const mxArray* m) {
    if (!is_int(m))
      throw std::runtime_error("bad data type");
    if (mxGetNumberOfElements(m) != 2)
      throw std::runtime_error("bad shape");
    int_t* d = (int_t*)mxGetData(m);
    return Point(d[0], d[1]);
  }
}
