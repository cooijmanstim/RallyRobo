#include <algorithm>

#include <boost/none.hpp>

#include "point.hpp"
#include "direction.hpp"
#include "robot.hpp"

#include "matlab.hpp"

Robot::Robot(RobotIndex identity, Point position, DirectionIndex direction)
  : identity(identity),
    position(position), direction(direction),
    respawn_position(position), respawn_direction(direction),
    next_checkpoint(1),
    damage(0), state(Active), is_virtual(false)
{
}

Robot::~Robot() {
}

bool Robot::is_active()    const { return state == Active; }
bool Robot::is_waiting()   const { return state == Waiting; }
bool Robot::is_destroyed() const { return state == Destroyed; }

bool Robot::obstructs() const {
  return !is_virtual && state != Waiting;
}

bool Robot::can_shoot() const {
  return is_active() && !is_virtual;
}

bool Robot::can_take_damage() const {
  return is_active() && !is_virtual;
}

void Robot::rotate(Rotation dd) {
  direction = Direction::rotate(direction, dd);
}

void Robot::take_damage() {
  damage++;
  if (damage > MaximumDamage)
    destroy();
}

void Robot::repair() {
  damage = std::max(0U, damage - 1);
}

void Robot::destroy() {
  state = Destroyed;
}

void Robot::wait() {
  state = Waiting;
}

void Robot::respawn() {
  position = respawn_position;
  direction = respawn_direction;
  damage = 0;
  state = Active;
  // always respawn as virtual; the robot will be devirtualized if necessary
  // after all respawns are complete.  this way simultaneous respawns can be
  // handled independently.
  virtualize();
}

void Robot::virtualize() {
  is_virtual = true;
}

void Robot::devirtualize() {
  is_virtual = false;
}

Deck Robot::vacate_registers() {
  Deck cards;
  int ni = std::min(NRegisters, MaximumDamage - damage);
  for (int i = 0; i < ni; i++) {
    cards.insert(*registers[i]);
    registers[i] = boost::none;
  }
  return cards;
}

Robot Robot::from_mxStruct(mxArray* mrobots, RobotIndex i) {
  Robot robot;

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

  kak(position, Point::from_mxArray);
  kak(direction, mex::uint_from_mxArray);
  kak(respawn_position, Point::from_mxArray);
  kak(respawn_direction, mex::uint_from_mxArray);
  kak(next_checkpoint, mex::uint_from_mxArray);
  kak(state, mex::uint_from_mxArray);
  kak(is_virtual, mex::bool_from_mxArray);
  kak(registers, registers_from_mxArray);

  #undef kak

  return robot;
}

void Robot::into_mxStruct(mxArray* mrobots, RobotIndex i) {
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

  #define kak(key, processor) mxSetField(mrobots, i, #key, processor(this->key));
  kak(position, Point::to_mxArray);
  kak(direction, mex::uint_to_mxArray);
  kak(respawn_position, Point::to_mxArray);
  kak(respawn_direction, mex::uint_to_mxArray);
  kak(next_checkpoint, mex::uint_to_mxArray);
  kak(state, mex::uint_to_mxArray);
  kak(is_virtual, mex::bool_to_mxArray);
  kak(registers, registers_to_mxArray);
  #undef kak
}
