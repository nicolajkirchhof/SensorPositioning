// Boost.Geometry (aka GGL, Generic Geometry Library)
//
// Copyright Barend Gehrels 2007-2009, Geodan, Amsterdam, the Netherlands
// Copyright Bruno Lalande 2008, 2009
// Use, modification and distribution is subject to the Boost Software License,
// Version 1.0. (See accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)
//
// bpoly_polygon_type Example

#include <algorithm> // for reverse, unique
#include <iostream>
#include <string>

#include <boost/geometry.hpp>
#include <boost/geometry/geometries/ring.hpp>
#include <boost/geometry/geometries/point_xy.hpp>
#include <boost/geometry/geometries/polygon.hpp>
#include <boost/geometry/geometries/linestring.hpp>
#include <boost/geometry/geometries/adapted/c_array.hpp>
//#include <boost/geometry/geometries/adapted/boost_tuple.hpp>

#include <boost/assign.hpp>
//#include <boost/geometry/geometries/adapted/boost_range/filtered.hpp>

//#include <boost/geometry/geometries/cartesian2d.hpp>
//#include <boost/geometry/geometries/adapted/c_array_cartesian.hpp>
//#include <boost/geometry/geometries/adapted/std_as_linestring.hpp>
//#include <boost/geometry/multi/multi.hpp>

//std::string boolstr(bool v)
//{
//    return v ? "true" : "false";
//}

#include <boost/geometry/geometries/register/ring.hpp>
#include <boost/geometry/geometries/register/point.hpp>

#include "..\bpolyclip\generic_range.h"

namespace bg = boost::geometry;
typedef generic_range::Pair<double( *)[2]> bpoly_range_type;
typedef bg::model::point<double, 2, bg::cs::cartesian> bpoly_point_type;
typedef bg::model::polygon<bpoly_point_type, false, false> bpoly_polygon_type;
BOOST_GEOMETRY_REGISTER_C_ARRAY_CS(cs::cartesian)
//BOOST_GEOMETRY_REGISTER_RING(std::vector<bpoly_point_type>)
BOOST_GEOMETRY_REGISTER_RING(bpoly_range_type)


////typedef boost::geometry::model::d2::point_xy<double> point_2d;
//typedef boost::geometry::model::point<double, 2, boost::geometry::cs::cartesian> point_2d;
////BOOST_GEOMETRY_REGISTER_POINT(double[2]);
//typedef bg::model::d2::point_xy<double> point;
////typedef model::box<point> box;
//typedef bg::model::bpoly_polygon_type<point, false, false> bpoly_polygon_type;

//BOOST_GEOMETRY_REGISTER_RING(std::vector<point_2d>)

void resize_and_append(bpoly_polygon_type &mypoly, const double(*coor1)[5][2], const double(*coor2)[3][2])
{
	std::cout << &mypoly.inners() << " " << &mypoly.outer() << std::endl;

	mypoly.inners().resize(2);	    

	std::cout << &mypoly.inners() << " " << &mypoly.outer() << std::endl;

    /*bg::assign_points(mypoly, *coor1);*/
	bg::append(mypoly, *coor1, -1);

	std::cout << &mypoly.inners() << " " << &mypoly.outer() << std::endl;
    //bg::interior_rings(mypoly).resize(1);

    bg::append(mypoly, *coor2, 0);
	bg::append(mypoly, *coor2, 1);
    return;
};

int main(void)
{
    //	using namespace std;

    const double coor[][2] = {
        {0.0, 1.3}, {2.4, 1.7}, {2.1, 1.8}, {1.4, 1.2}, {0, 1.6}
    };

    const double coor1[][2] = {
        {0.0, 0.3}, {2.4, 0}, {2.8, 1.8}, {3.4, 1.2}, {0, 1.6}
    };
    const double coor2[][2] = {
        {1.0, 0.5}, {2.0, 0.6}, {2.0, 1.0}
    };

    bpoly_polygon_type mypoly, ppoly;

    resize_and_append(mypoly, &coor1, &coor2);
	resize_and_append(ppoly, &coor, &coor2);

    // 		bg::assign_points(mypoly, coor1);

    //mypoly.inners().resize(1);
    // 		//bg::interior_rings(mypoly).resize(1);

    // 		bg::append(mypoly, coor2, 0);
    //		//boost::geometry::append(mypoly, coor2, 1);

    //		assign_points(ppoly, coor);

    		 std::list<bpoly_polygon_type> output;

    //		 std::cout << dsv(mypoly) << endl;
    //		 std::cout << dsv(ppoly) << endl;

    //		 //correct(mypoly);
    //		 //correct(ppoly);

    //		 //std::cout << dsv(mypoly) << endl;
    //		 //std::cout << dsv(ppoly) << endl;



    bg::difference(mypoly, ppoly, output);

    //boost::geometry::assign_points(mypoly.outer(), coor1);
    //append(mypoly.inners(), coor2);


    //using namespace boost::geometry;

    //// Define a bpoly_polygon_type and fill the outer ring.
    //// In most cases you will read it from a file or database
    //bpoly_polygon_type_2d poly;
    //{
    //    const double coor[][2] = {
    //        {2.0, 1.3}, {2.4, 1.7}, {2.8, 1.8}, {3.4, 1.2}, {3.7, 1.6},
    //        {3.4, 2.0}, {4.1, 3.0}, {5.3, 2.6}, {5.4, 1.2}, {4.9, 0.8}, {2.9, 0.7},
    //        {2.0, 1.3} // closing point is opening point
    //        };
    //    assign(poly, coor);
    //}

    //// bpoly_polygon_types should be closed, and directed clockwise. If you're not sure if that is the case,
    //// call the correct algorithm
    //correct(poly);

    //// bpoly_polygon_types can be streamed as text
    //// (or more precisely: as DSV (delimiter separated values))
    //std::cout << dsv(poly) << std::endl;

    //// As with lines, bounding box of bpoly_polygon_types can be calculated
    //box_2d b;
    //envelope(poly, b);
    //std::cout << dsv(b) << std::endl;

    //// The area of the bpoly_polygon_type can be calulated
    //std::cout << "area: " << area(poly) << std::endl;

    //// And the centroid, which is the center of gravity
    //point_2d cent;
    //centroid(poly, cent);
    //std::cout << "centroid: " << dsv(cent) << std::endl;


    //// The number of points have to called per ring separately
    //std::cout << "number of points in outer ring: " << poly.outer().size() << std::endl;

    //// bpoly_polygon_types can have one or more inner rings, also called holes, donuts, islands, interior rings.
    //// Let's add one
    //{
    //    poly.inners().resize(1);
    //    linear_ring<point_2d>& inner = poly.inners().back();

    //    const double coor[][2] = { {4.0, 2.0}, {4.2, 1.4}, {4.8, 1.9}, {4.4, 2.2}, {4.0, 2.0} };
    //    assign(inner, coor);
    //}

    //correct(poly);

    //std::cout << "with inner ring:" << dsv(poly) << std::endl;
    //// The area of the bpoly_polygon_type is changed of course
    //std::cout << "new area of bpoly_polygon_type: " << area(poly) << std::endl;
    //centroid(poly, cent);
    //std::cout << "new centroid: " << dsv(cent) << std::endl;

    //// You can test whether points are within a bpoly_polygon_type
    //std::cout << "point in bpoly_polygon_type:"
    //    << " p1: "  << boolstr(within(make<point_2d>(3.0, 2.0), poly))
    //    << " p2: "  << boolstr(within(make<point_2d>(3.7, 2.0), poly))
    //    << " p3: "  << boolstr(within(make<point_2d>(4.4, 2.0), poly))
    //    << std::endl;

    //// As with linestrings and points, you can derive from bpoly_polygon_type to add, for example,
    //// fill color and stroke color. Or SRID (spatial reference ID). Or Z-value. Or a property map.
    //// We don't show this here.

    //// Clip the bpoly_polygon_type using a bounding box
    //box_2d cb(make<point_2d>(1.5, 1.5), make<point_2d>(4.5, 2.5));
    //typedef std::vector<bpoly_polygon_type_2d > bpoly_polygon_type_list;
    //bpoly_polygon_type_list v;

    //intersection_inserter<bpoly_polygon_type_2d>(cb, poly, std::back_inserter(v));
    //std::cout << "Clipped output bpoly_polygon_types" << std::endl;
    //for (bpoly_polygon_type_list::const_iterator it = v.begin(); it != v.end(); ++it)
    //{
    //    std::cout << dsv(*it) << std::endl;
    //}

    //typedef multi_bpoly_polygon_type<bpoly_polygon_type_2d> bpoly_polygon_type_set;
    //bpoly_polygon_type_set ps;
    //union_inserter<bpoly_polygon_type_2d>(cb, poly, std::back_inserter(ps));

    //bpoly_polygon_type_2d hull;
    //convex_hull(poly, hull);
    //std::cout << "Convex hull:" << dsv(hull) << std::endl;

    //// If you really want:
    ////   You don't have to use a vector, you can define a bpoly_polygon_type with a deque
    ////   You can specify the container for the points and for the inner rings independantly

    //typedef bpoly_polygon_type<point_2d, std::vector, std::deque> bpoly_polygon_type_type;
    //bpoly_polygon_type_type poly2;
    //ring_type<bpoly_polygon_type_type>::type& ring = exterior_ring(poly2);
    //append(ring, make<point_2d>(2.8, 1.9));
    //append(ring, make<point_2d>(2.9, 2.4));
    //append(ring, make<point_2d>(3.3, 2.2));
    //append(ring, make<point_2d>(3.2, 1.8));
    //append(ring, make<point_2d>(2.8, 1.9));
    //std::cout << dsv(poly2) << std::endl;

    return 0;
}