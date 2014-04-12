CYGPATH=d:/cygwin
MATLABROOT=/cygdrive/c/Users/Nico/PortableApps/Matlab/R2012b
INCLUDE=/cygdrive/d/libs/boost-trunk
# echo $INCLUDE
# CC=$(MINGWPATH)/bin/x86_64-w64-mingw32-gcc 
# CC=./bin/
# MEXSRC=binpolygon
# MEXSRC=binpolygon.cpp
# LIBS=-L$MATLABROOT/bin/win64 -L$MATLABROOT/extern/lib/win64/microsoft -lmex -lmx -lmat -lmwlapack -lmwblas -leng
# CC=./bin/x86_64-w64-mingw32-gcc
# CFLAG=-Wall -m64 -O3 -I$MATLABROOT/extern/include $SRC $LIBS -o $EXE
# MEXFLAG=-m64 -shared -DMATLAB_MEX_FILE -I$MATLABROOT/extern/include --export-all-symbols $LIBS $MEXSRC -o $MEXTGT.mexw64
# echo "$CC $MEXFLAG -ladvapi32 -luser32 -lgdi32 -lkernel32 -lmingwex"
x86_64-w64-mingw32-g++ -m64 -shared -DMATLAB_MEX_FILE -I/cygdrive/c/Users/Nico/PortableApps/Matlab/R2012b/extern/include -I/cygdrive/d/libs/boost-trunk -Wl,--export-all-symbols  -L/cygdrive/c/Users/Nico/PortableApps/Matlab/R2012b/bin/win64 -L/cygdrive/c/Users/Nico/PortableApps/Matlab/R2012b/extern/lib/win64/microsoft -lmex -lmx -lmat -lmwlapack -lmwblas -leng bpolyclip.cpp -o bpolyclip.mexw64
