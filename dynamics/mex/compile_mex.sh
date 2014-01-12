MATLAB='/home/tim/install/MATLAB/R2011a'
MFLAGS="-DMATLAB_MEX_FILE"
MINCLUDE="-I$MATLAB/extern/include"
MLIBS="-L$MATLAB/bin/glnx86 -lmx -lmex -lmat"

CXX='g++-4.4'
CXXFLAGS="-std=gnu++0x -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -fPIC -pthread -O $MFLAGS -shared"
CXXINCLUDE="$MINCLUDE"
CXXLIBS="$RPATH $MLIBS -lm"
CXXOPTIMFLAGS='-DNDEBUG'
CXXDEBUGFLAGS='-g'

STATICDIR=../bin/gcc-std0x/debug/link-static

# build libgame.a
PREVWD=`pwd`
cd ..
b2
cd $PREVWD

# build perform_turn.mexglx
$CXX $CXXFLAGS $CXXDEBUGFLAGS $CXXINCLUDE $CXXLIBS perform_turn.cpp -o perform_turn.mexglx
