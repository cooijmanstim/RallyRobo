#pragma once

#include <stdexcept>

#define __STDC_UTF_16__
#include "mex.h"
#include "matrix.h"

#include "../game.hpp"

namespace mex {
  typedef  int16_T  int_t;
  typedef uint16_T uint_t;
  typedef     bool bool_t;

  mxClassID  int_t_classid = mxINT16_CLASS;
  mxClassID uint_t_classid = mxINT16_CLASS;
  
  bool is_int (const mxArray *m) { return mxGetClassID(m) ==  int_t_classid; }
  bool is_uint(const mxArray *m) { return mxGetClassID(m) == uint_t_classid; }
  bool is_bool(const mxArray *m) { return mxIsLogical(m); }

  int_t int_from_mxArray(const mxArray *m) {
    if (!is_int(m))
      throw std::runtime_error("expected int_t array");
    if (mxGetNumberOfElements(m) != 1)
      throw std::runtime_error("expected scalar");
    return *(int_t*)mxGetData(m);
  }

  uint_t uint_from_mxArray(const mxArray *m) {
    if (!is_uint(m))
      throw std::runtime_error("expected int_t array");
    if (mxGetNumberOfElements(m) != 1)
      throw std::runtime_error("expected scalar");
    return *(uint_t*)mxGetData(m);
  }

  bool_t bool_from_mxArray(const mxArray *m) {
    if (!is_bool(m))
      throw std::runtime_error("expected logical array");
    if (mxGetNumberOfElements(m) != 1)
      throw std::runtime_error("expected scalar");
    return *(bool_t*)mxGetLogicals(m);
  }

  mxArray* uint_to_mxArray(uint_t i) {
    mxArray* m = mxCreateNumericMatrix(1, 1, uint_t_classid, mxREAL);
    *(uint_t*)mxGetData(m) = i;
    return m;
  }

  mxArray* int_to_mxArray(int_t i) {
    mxArray* m = mxCreateNumericMatrix(1, 1, int_t_classid, mxREAL);
    *(int_t*)mxGetData(m) = i;
    return m;
  }

  mxArray* bool_to_mxArray(bool_t b) {
    return mxCreateLogicalScalar(b);
  }



  Point point_from_mxArray(const mxArray* m) {
    if (!is_int(m))
      throw std::runtime_error("bad data type");
    if (mxGetNumberOfElements(m) != 2)
      throw std::runtime_error("bad shape");
    int_t* d = (int_t*)mxGetData(m);
    return Point(d[0], d[1]);
  }

  Robot robot_from_mxStruct(const mxArray* mrobots, RobotIndex i) {
    Robot robot;
    robot.identity = i;
  
    auto direction_from_mxArray = [](mxArray* mdirection) {
      uint_t direction = uint_from_mxArray(mdirection);
      if (direction >= Direction::NDirections)
        throw std::runtime_error("invalid direction specifier");
      return static_cast<DirectionIndex>(direction);
    };

    auto state_from_mxArray = [](mxArray* mstate) {
      uint_t state = uint_from_mxArray(mstate);
      if (state >= Robot::NStates)
        throw std::runtime_error("invalid state specifier");
      return static_cast<Robot::State>(state);
    };

    auto registers_from_mxArray = [](mxArray* mregisters) {
      if (!mxIsStruct(mregisters))
        throw std::runtime_error("expected a structure array");
  
      if (mxGetNumberOfElements(mregisters) != Robot::NRegisters)
        throw std::runtime_error(str(format("expected %1% registers") % Robot::NRegisters));
  
      boost::array<boost::optional<Card>, Robot::NRegisters> registers;
      for (size_t i = 0; i < Robot::NRegisters; i++) {
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
        robot.key = processor(mxGetField(mrobots, i, #key));      \
      } catch (std::runtime_error& ex) {                            \
        mexErrMsgIdAndTxt("RR:BadArgument", str(format("failed to process state.robots(%1%)." #key ": %2%") % i % ex.what()).c_str()); \
      }
  
    kak(position, point_from_mxArray);
    kak(direction, direction_from_mxArray);
    kak(respawn_position, point_from_mxArray);
    kak(respawn_direction, direction_from_mxArray);
    kak(next_checkpoint, uint_from_mxArray);
    kak(state, state_from_mxArray);
    kak(is_virtual, bool_from_mxArray);
    kak(registers, registers_from_mxArray);
  
    #undef kak
  
    return robot;
  }

  void game_from_mxArray(const mxArray* mgame, Game& cgame) {
    const mxArray* mboard       = mxGetField(mgame, 0, "board"),
                 * mcheckpoints = mxGetField(mgame, 0, "checkpoints"),
                 * mrobots      = mxGetField(mgame, 0, "robots");
  
    if (!mboard || !mcheckpoints || !mrobots)
      mexErrMsgIdAndTxt("RR:BadArgument", "argument is not a game structure");
  
    {
      if (!is_bool(mboard))
        mexErrMsgIdAndTxt("RR:BadArgument", "board should be a logical array");
      
      const mwSize* mdimensions = mxGetDimensions(mboard);
      if (mxGetNumberOfDimensions(mboard) != 3 ||
          mdimensions[0] != Game::BoardHeight ||
          mdimensions[1] != Game::BoardWidth)
        mexErrMsgIdAndTxt("RR:BadArgument", str(format("size(board) should be [%1% %2% %3%]") % Game::BoardHeight % Game::BoardWidth % Feature::NFeatures).c_str());
  
      bool_t* dboard = mxGetLogicals(mboard);
      mwSize nsubs = 3;
      mwIndex subs[] = {0, 0, 0};
      for (subs[0] = 0; subs[0] < Game::BoardHeight; subs[0]++)
        for (subs[1] = 0; subs[1] < Game::BoardWidth; subs[1]++)
          for (subs[2] = 0; subs[2] < Feature::NFeatures; subs[2]++)
            cgame.board[subs[0]+1][subs[1]+1][subs[2]] = dboard[mxCalcSingleSubscript(mboard, nsubs, subs)];
    }
  
    {
      const mwSize* mdimensions = mxGetDimensions(mcheckpoints);
      if (mxGetNumberOfDimensions(mcheckpoints) != 2 ||
          mdimensions[1] != 2)
        mexErrMsgIdAndTxt("RR:BadArgument", "size(checkpoints) should be [n 2]");
  
      if (!is_int(mcheckpoints))
        mexErrMsgIdAndTxt("RR:BadArgument", "checkpoints should be int_t");
  
      int_t* dcheckpoints = (int_t*)mxGetData(mcheckpoints);
      mwSize nsubs = 2;
      mwIndex subs[] = {0, 0};
      int_t x[2];
      for (subs[0] = 0; subs[0] < mdimensions[0]; subs[0]++) {
        for (subs[1] = 0; subs[1] < 2; subs[1]++)
          x[subs[1]] = dcheckpoints[mxCalcSingleSubscript(mcheckpoints, nsubs, subs)];
        cgame.add_checkpoint(Point(x[0], x[1]));
      }
    }
  
    {
      if (!mxIsStruct(mrobots))
        mexErrMsgIdAndTxt("RR:BadArgument", "state.robots should be a structure array");
  
      size_t n = mxGetNumberOfElements(mrobots);
      for (size_t i = 0; i < n; i++)
        cgame.robots.push_back(boost::shared_ptr<Robot>(new Robot(robot_from_mxStruct(mrobots, i))));
    }
  }
  


  mxArray* point_to_mxArray(Point x) {
    mxArray* m = mxCreateNumericMatrix(1, 2, int_t_classid, mxREAL);
    int_t* d = (int_t*)mxGetData(m);
    d[0] = x[0]; d[1] = x[1];
    return m;
  }

  void robot_into_mxStruct(mxArray* mrobots, RobotIndex i, const Robot& robot) {
    auto registers_to_mxArray = [](const boost::array<boost::optional<Card>, Robot::NRegisters>& registers) {
      const char *augh[] = {"priority", "translation", "rotation"};
      mwSize ndims = 1;
      mwSize dims[] = {Robot::NRegisters};
      mxArray* mregisters = mxCreateStructArray(ndims, dims, 3, augh);
      
      for (std::size_t i = 0; i < Robot::NRegisters; i++) {
        if (!registers[i])
          continue;
  
        mxSetField(mregisters, i, "priority",    int_to_mxArray(registers[i]->priority));
        mxSetField(mregisters, i, "translation", int_to_mxArray(registers[i]->translation));
        mxSetField(mregisters, i, "rotation",    int_to_mxArray(registers[i]->rotation));
      }

      return mregisters;
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
  
  mxArray* game_to_mxArray(const Game& cgame) {
    mxArray* mboard, * mcheckpoints, * mrobots;
  
    {
      mwSize ndim = 3;
      mwSize dims[] = {Game::BoardHeight, Game::BoardWidth, Feature::NFeatures};
      mboard = mxCreateLogicalArray(ndim, dims);
      bool_t* dboard = mxGetLogicals(mboard);
      mwSize nsubs = 3;
      mwIndex subs[] = {0, 0, 0};
      for (subs[0] = 0; subs[0] < dims[0]; subs[0]++)
        for (subs[1] = 0; subs[1] < dims[1]; subs[1]++)
          for (subs[2] = 0; subs[2] < dims[2]; subs[2]++)
            dboard[mxCalcSingleSubscript(mboard, nsubs, subs)] = cgame.board[subs[0]+1][subs[1]+1][subs[2]];
    }
  
    {
      mcheckpoints = mxCreateNumericMatrix(cgame.checkpoints.size(), 2, int_t_classid, mxREAL);
      int_t* dcheckpoints = (int_t*)mxGetData(mcheckpoints);
      mwSize nsubs = 2;
      mwIndex subs[] = {0, 0};
      for (subs[0] = 0; subs[0] < cgame.checkpoints.size(); subs[0]++)
        for (subs[1] = 0; subs[1] < 2; subs[1]++)
          dcheckpoints[mxCalcSingleSubscript(mcheckpoints, nsubs, subs)] = cgame.checkpoints[subs[0]].x[subs[1]];
    }
  
    {
      const char* pfft[] = {"position", "direction",
                            "respawn_position", "respawn_direction",
                            "next_checkpoint",
                            "state", "is_virtual", "registers"};
      mrobots = mxCreateStructMatrix(1, 1, 3, pfft);
  
      for (size_t i = 0; i < cgame.robots.size(); i++)
        robot_into_mxStruct(mrobots, i, *cgame.robots[i]);
    }
  
    const char* fieldnames[] = {"board", "checkpoints", "robots"};
    mxArray* mgame = mxCreateStructMatrix(1, 1, 3, fieldnames);
    mxSetField(mgame, 0, "board",       mboard);
    mxSetField(mgame, 0, "checkpoints", mcheckpoints);
    mxSetField(mgame, 0, "robots",      mrobots);
    return mgame;
  }
}
