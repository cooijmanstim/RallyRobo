#pragma once

#include <boost/array.hpp>
#include <boost/optional.hpp>

#include "point.hpp"
#include "direction.hpp"
#include "checkpoint.hpp"

typedef unsigned char RobotIndex;

// TODO move this somewhere
#define NRegisters 5

class Robot {
public:
  RobotIndex identity;
  Point position;
  DirectionIndex direction;
  Point respawn_position;
  DirectionIndex respawn_direction;
  CheckpointIndex next_checkpoint;
  unsigned int damage;

  typedef enum State { Active, Destroyed, Waiting } State;
  State state;

  // virtuality is orthogonal to state
  bool is_virtual;

  boost::array<boost::optional<Card>, NRegisters> registers;

  Robot(RobotIndex identity, Point position, DirectionIndex direction);
  Robot(const Robot& that);
  ~Robot();
  Robot& operator=(const Robot& that);

  bool is_active();
  bool is_waiting();
  bool is_destroyed();

  bool obstructs();
  
  void rotate(Rotation dd);
  
  void wait();
  void respawn();
  void virtualize();
  void devirtualize();
  void take_damage();
  void repair();
};
