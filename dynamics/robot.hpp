#pragma once

#include <boost/array.hpp>
#include <boost/optional.hpp>

#include "point.hpp"
#include "direction.hpp"
#include "checkpoint.hpp"

typedef unsigned char RobotIndex;

// TODO move this somewhere
const size_t NRegisters = 5;
const unsigned int MaximumDamage = 9;

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
  ~Robot();

  bool is_active() const;
  bool is_waiting() const;
  bool is_destroyed() const;

  bool obstructs() const;
  bool can_take_damage() const;
  
  void rotate(Rotation dd);
  
  void take_damage();
  void repair();
  void destroy();
  void wait();
  void respawn();
  void virtualize();
  void devirtualize();

  Deck vacate_registers();
};
