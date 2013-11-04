#include <stdio.h>
#include <string.h>
#include <assert.h>

#include <stdbool.h>

#define BOARD_SIZE 12

typedef struct {
  short x[2];
} Point;

#define SUBSCRIPT(a, x) (a[x.x[0]][x.x[1]])

inline Point make_point(int y, int x) {
  Point p = {{y, x}};
  return p;
}

void point_set(Point *dest, Point *src) {
  dest->x[0] = src->x[0];
  dest->x[1] = src->x[1];
}

inline Point point_plus(Point a, Point b) {
  Point p = {{a.x[0] + b.x[0], a.x[1] + b.x[1]}};
  return p;
}

inline int point_equal(Point a, Point b) {
  return a.x[0] == b.x[0] && a.x[1] == b.x[1];
}

typedef enum {
  DIR_EAST, DIR_NORTH, DIR_WEST, DIR_SOUTH,
} Direction;

const Point DIRECTION_VECTORS[] = {
  {{ 0,  1}},
  {{ 1,  0}},
  {{ 0, -1}},
  {{-1,  0}},
};

typedef struct {
  bool pit                  : 1;
  bool repair               : 1;
  bool wall_east            : 1;
  bool wall_north           : 1;
  bool wall_west            : 1;
  bool wall_south           : 1;
  bool conveyor_east        : 1;
  bool conveyor_north       : 1;
  bool conveyor_west        : 1;
  bool conveyor_south       : 1;
  bool conveyor_turning_cw  : 1;
  bool conveyor_turning_ccw : 1;
} Tile;

typedef struct {
  Point position;
  Direction direction;
  unsigned short last_checkpoint;
} Robot;

typedef struct {
  unsigned short nrobots;
  Robot *robots;
  unsigned short ncheckpoints;
  Point *checkpoints;
  Tile board[BOARD_SIZE][BOARD_SIZE];
} Game;

#define SUCCESS 0
#define OBSTRUCTED 1

bool robot_can_leave(const Game *game, int irobot, Point x, Direction dir) {
  assert(game != NULL);

  const Tile tile = SUBSCRIPT(game->board, x);

  if (tile.pit)
    return false;

  switch (dir) {
  case DIR_EAST:  return tile.wall_east;
  case DIR_NORTH: return tile.wall_north;
  case DIR_WEST:  return tile.wall_west;
  case DIR_SOUTH: return tile.wall_south;
  default: assert(false);
  }
}

bool robot_can_enter(const Game *game, int irobot, Point x, Direction dir) {
  assert(game != NULL);

  const Tile tile = SUBSCRIPT(game->board, x);

  switch (dir) {
  case DIR_EAST:  return tile.wall_west;
  case DIR_NORTH: return tile.wall_south;
  case DIR_WEST:  return tile.wall_east;
  case DIR_SOUTH: return tile.wall_north;
  default: assert(false);
  }
}

/* Move the indicated robot in the direction 'dx', pushing other robots
 * if they are in the way.  Does not move if the move is obstructed or
 * would involve pushing a robot through an obstruction.
 * Returns SUCCESS if successful, otherwise returns an error code.
 * Modifies game.
 */
int robot_move_maybe(Game *game, int irobot, Direction dir) {
  assert(game != NULL);

  Point x = game->robots[irobot].position;
  Point xnew = point_plus(x, DIRECTION_VECTORS[dir]);

  if (!robot_can_leave(game, irobot, x,    dir) ||
      !robot_can_enter(game, irobot, xnew, dir)) {
    return OBSTRUCTED;
  }

  /* if there is a robot at the destination, try to push it */
  for (int jrobot = 0; jrobot < game->nrobots; jrobot++) {
    if (point_equal(game->robots[jrobot].position, xnew)) {
      int ret = robot_move_maybe(game, jrobot, dir);
      if (ret != SUCCESS) {
        return OBSTRUCTED;
      }
      break;
    }
  }

  /* finally, move irobot */
  point_set(&game->robots[irobot].position, &xnew);
  return SUCCESS;
}
