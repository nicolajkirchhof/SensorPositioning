#include <iostream>

#include <boost/assign.hpp>

#include <boost/geometry.hpp>
#include <boost/geometry/geometries/polygon.hpp>
#include <boost/geometry/geometries/adapted/boost_tuple.hpp>

BOOST_GEOMETRY_REGISTER_BOOST_TUPLE_CS(cs::cartesian)

int main()
{
    using boost::assign::tuple_list_of;
    using boost::make_tuple;
    using boost::geometry::append;

    typedef boost::geometry::model::polygon<boost::tuple<int, int> > polygon;

    polygon poly;

	// Create an interior ring (append does not do this automatically)
    boost::geometry::interior_rings(poly).resize(1);

    // Append a range
    //append(poly, tuple_list_of(0, 0)(0, 10)(11, 11)(10, 0)); 
	boost::geometry::assign_points(poly, tuple_list_of(0, 0)(0, 10)(11, 11)(10, 0)); 
    // Append a point (in this case the closing point)
    append(poly, make_tuple(0, 0));

    // Append a range to the interior ring
    append(poly, tuple_list_of(2, 2)(2, 5)(6, 6)(5, 2), 0); 
    // Append a point to the first interior ring
    append(poly, make_tuple(2, 2), 0);

    std::cout << boost::geometry::dsv(poly) << std::endl;

    return 0;
}