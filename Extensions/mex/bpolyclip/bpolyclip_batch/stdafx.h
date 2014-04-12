// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include <iostream>
#include <list>

#include <boost/geometry.hpp>
#include <boost/geometry/geometries/register/point.hpp>
#include <boost/geometry/geometries/register/ring.hpp>
#include <boost/geometry/geometries/point.hpp>
#include <boost/geometry/geometries/polygon.hpp>
#include <boost/geometry/geometries/adapted/c_array.hpp>

#include <boost/cstdint.hpp>
#include <boost/geometry/multi/geometries/multi_polygon.hpp>
#include <boost/geometry/multi/geometries/register/multi_polygon.hpp>
#include <boost/foreach.hpp>
#include <boost/range.hpp>

#include <string>
#include <sstream>
#include <vector>


//// TODO: reference additional headers your program requires here
//#include <iostream>
//#include <sstream>
//
//
////Gives Matlab interfacing.  Linkage block specifies linkage
////convention used to link header file; makes the C header suitable for
////C++ use.  "mex.h" also includes "matrix.h" to provide MX functions
////to support Matlab data types, along with the standard header files
////<stdio.h>, <stdlib.h>, and <stddef.h>.
////extern "C" {
//#include <math.h>
//#include <mex.h>
//// only needed if matlab should be started from vc++
////#include <engine.h>
//#define  BUFSIZE 256
////}