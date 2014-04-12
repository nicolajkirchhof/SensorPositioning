// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include <iostream>
#include <list>
#include <string>
#include <sstream>
#include <vector>

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

#ifndef NO_MATLAB
//Gives Matlab interfacing.  Linkage block specifies linkage
//convention used to link header file; makes the C header suitable for
//C++ use.  "mex.h" also includes "matrix.h" to provide MX functions
//to support Matlab data types, along with the standard header files
//<stdio.h>, <stdlib.h>, and <stddef.h>.
#include <math.h>
#include <mex.h>
//#include <engine.h>
//#define  BUFSIZE 256
#endif

#include "generic_range.hpp"
#include "spike_removal_nico.hpp"
#include "touch_remove_nico.hpp"
#include "has_self_intersections_nico.hpp"












// TODO: reference additional headers your program requires here

//#include <iostream>
//#include <list>
//
//#include <boost/geometry.hpp>
//#include <boost/geometry/geometries/register/point.hpp>
//#include <boost/geometry/geometries/register/ring.hpp>
////#include <boost/geometry/geometries/point_xy.hpp>
//#include <boost/geometry/geometries/point.hpp>
//#include <boost/geometry/geometries/polygon.hpp>
//#include <boost/geometry/geometries/adapted/c_array.hpp>
////#include <boost/geometry/io/wkt/wkt.hpp>
////#include <boost/tuple/tuple.hpp>
////#include <boost/geometry/geometries/adapted/boost_tuple.hpp>
////#include <boost/range/concepts.hpp>
//
////#include <boost/foreach.hpp>
//
//#include <boost/cstdint.hpp>
////#include <boost/geometry/extensions/algorithms/remove_spikes.hpp>
//#include <boost/geometry/multi/geometries/multi_polygon.hpp>
//#include <boost/geometry/multi/geometries/register/multi_polygon.hpp>
//#include <boost/foreach.hpp>
//#include <boost/range.hpp>
//
//#include <string>
//#include <sstream>
//
////Gives Matlab interfacing.  Linkage block specifies linkage
////convention used to link header file; makes the C header suitable for
////C++ use.  "mex.h" also includes "matrix.h" to provide MX functions
////to support Matlab data types, along with the standard header files
////<stdio.h>, <stdlib.h>, and <stddef.h>.
//#include <math.h>
//#include <mex.h>
////#include <engine.h>
//#define  BUFSIZE 256
