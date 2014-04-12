// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include "targetver.h"

#include <stdio.h>
#include <tchar.h>

//#include "..\bpolyclip\bpolyclip.hpp"
#include "..\bpolyclip\has_self_intersections_nico.hpp"
#include "..\bpolyclip\spike_removal_nico.hpp"
#include "..\bpolyclip\touch_remove_nico.hpp"
#include <boost\geometry\io\io.hpp>
#include <boost\foreach.hpp>
#include <boost/geometry/geometries/register/point.hpp>
#include <boost/geometry/geometries/register/ring.hpp>
#include <boost/geometry/geometries/point.hpp>
#include <boost/geometry/geometries/polygon.hpp>
#include <boost/geometry/geometries/adapted/c_array.hpp>
#include <boost/geometry/multi/multi.hpp>

#include <boost/cstdint.hpp>
#include <boost/geometry/multi/geometries/multi_polygon.hpp>
#include <boost/geometry/multi/geometries/register/multi_polygon.hpp>
#include <boost/geometry/geometry.hpp>
#include <boost/geometry/geometries/segment.hpp>

#include <boost/geometry/algorithms/detail/overlay/turn_info.hpp>
#include <boost/geometry/algorithms/detail/overlay/get_turns.hpp>
#include <boost/geometry/algorithms/detail/overlay/self_turn_points.hpp>

#include <boost/typeof/typeof.hpp>
#include <sstream>

#include <iostream>
#include <fstream>
#include <string>


// TODO: reference additional headers your program requires here
