#include "game.hpp"

class Test {
    Game game;

    Test() : game(// robots (position, direction, next_checkpoint)
                  {{ { 3, 1}, { 0,1}, 1 },
                   { { 4,11}, {-1,0}, 1 },
                   { { 8, 1}, {-1,0}, 1 },
                   { {11, 9}, { 1,0}, 1 }},
                  // checkpoint positions
                  { {12,1}, {8,9}, {2,8}, {9,5} })
    {
#define EF(FEATURE, POINTS) do {                                     \
            int points[][2] = POINTS;                                \
            for (int i = 0; i < sizeof(points); i++) {               \
            }                                                        \
        } while(0);
#define KAK(...) __VA_ARGS__
//                int point[2] = points[i];                            \
  //              /* the coordinates are specified in reverse order */ \
    //            game.board[point[1]][point[0]]. ## FEATURE = true;   \

        EF(pit, KAK({{8,5}, {9,5}, {3,7}, {6,10}}));
        EF(repair, KAK({{2,1}, {2,5}, {5,3}, {9,3}, {5,8}, {1,10}}));
        EF(conveyor_north, KAK({{3,1}, {3,2}, {3,3}, {7,4}, {7,5}}));
        EF(conveyor_east, KAK({{3,4}, {4,4}, {5,4}, {6,4}, {7,6}, {8,6}, {9,6}, {10,6}, {11,6}, {12,6}}));
        EF(conveyor_west, KAK({{1,6}, {2,6}, {3,6}, {4,6}, {5,7}, {6,7}, {7,7}, {8,7}, {9,7}, {10,7}, {11,7}, {12,7}}));
        EF(conveyor_south, KAK({{4,7}}));
        EF(conveyor_turning_ccw, KAK({{7,4}, {4,7}}));
        EF(conveyor_turning_cw, KAK({{7,6}, {3,4}, {4,6}}));
        EF(wall_east, KAK({{4,5}}));
        EF(wall_north, KAK({{10,2}, {4,5}, {7,7}, {3,10}}));
        EF(wall_west, KAK({{4,1}, {10,2}, {7,3}, {1,5}, {11,9}, {5,12}}));
        EF(wall_south, KAK({{6,1}}));
#undef EF
#undef KAK
    }
};
