// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

//#include "targetver.h"

#include <stdio.h>
#include <tchar.h>



// TODO: reference additional headers your program requires here
#include <iostream>
#include <list>
#include <string>
#include <sstream>

#include <boost/geometry.hpp>
#include <boost/geometry/geometries/point_xy.hpp>
#include <boost/geometry/geometries/polygon.hpp>
#include <boost/geometry/geometries/adapted/c_array.hpp>
//#include <boost/geometry/io/wkt/wkt.hpp>
//#include <boost/tuple/tuple.hpp>
//#include <boost/geometry/geometries/adapted/boost_tuple.hpp>
//#include <boost/range/concepts.hpp>

#include <boost/foreach.hpp>


//Gives Matlab interfacing.  Linkage block specifies linkage
//convention used to link header file; makes the C header suitable for
//C++ use.  "mex.h" also includes "matrix.h" to provide MX functions
//to support Matlab data types, along with the standard header files
//<stdio.h>, <stdlib.h>, and <stddef.h>.
extern "C" {
#include <math.h>
#include <mex.h>
#include <engine.h>
#define  BUFSIZE 256
}