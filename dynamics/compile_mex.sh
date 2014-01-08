MATLAB='/home/tim/install/MATLAB/R2011a'
MFLAGS="-DMATLAB_MEX_FILE"
MINCLUDE="-I$MATLAB/extern/include"
MLIBS="-L$TMW_ROOT/bin/$Arch -lmx -lmex -lmat"

CXX='g++'
CXXFLAGS="-std=gnu++0x -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -fPIC -pthread -O $MFLAGS"
CXXINCLUDE="$MINCLUDE"
CXXLIBS="$RPATH $MLIBS -lm"
CXXOPTIMFLAGS='-DNDEBUG'
CXXDEBUGFLAGS='-g'

STATICDIR=bin/gcc-std0x/debug/link-static

$CXX $CXXFLAGS $CXXDEBUGFLAGS $CXXINCLUDE $CXXLIBS perform_turn.cpp $STATICDIR/libgame.a -o perform_turn.mexglx
