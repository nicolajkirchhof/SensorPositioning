//#include "stdafx.h"
// TODO: reference additional headers your program requires here
#include <iostream>
#include <list>
#include <string>
#include <sstream>

#include <boost/geometry.hpp>
#include <boost/geometry/geometries/register/point.hpp>
#include <boost/geometry/geometries/register/ring.hpp>
#include <boost/geometry/geometries/point_xy.hpp>
#include <boost/geometry/geometries/point.hpp>
#include <boost/geometry/geometries/polygon.hpp>
#include <boost/geometry/geometries/adapted/c_array.hpp>
//#include <boost/geometry/io/wkt/wkt.hpp>
//#include <boost/tuple/tuple.hpp>
//#include <boost/geometry/geometries/adapted/boost_tuple.hpp>
//#include <boost/range/concepts.hpp>

//
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

//#include <boost/assign.hpp>


#include <boost/range.hpp>
#include <iterator>         // for std::iterator_traits, std::distance()




namespace Foo {
    //
    // Our sample UDT. A 'Pair'
    // will work as a range when the stored
    // elements are iterators.
    //
    template< class T >
    struct Pair {
        T first, last;
    };

} // namespace 'Foo'

BOOST_GEOMETRY_REGISTER_C_ARRAY_CS(cs::cartesian)
BOOST_GEOMETRY_REGISTER_RING(Foo::Pair<double(*)[2]>)

namespace boost {
    //
    // Specialize metafunctions. We must include the range.hpp header.
    // We must open the 'boost' namespace.
    //

    template< class T >
    struct range_mutable_iterator< Foo::Pair<T> > {
        typedef T type;
    };

    template< class T >
    struct range_const_iterator< Foo::Pair<T> > {
        //
        // Remark: this is defined similar to 'range_iterator'
        //         because the 'Pair' type does not distinguish
        //         between an iterator and a const_iterator.
        //
        typedef T type;
    };

} // namespace 'boost'
namespace Foo {
    //
    // The required functions. These should be defined in
    // the same namespace as 'Pair', in this case
    // in namespace 'Foo'.
    //

    template< class T >
    inline T range_begin(Pair<T> &x)
    {
        return x.first;
    }

    template< class T >
    inline T range_begin(const Pair<T> &x)
    {
        return x.first;
    }

    template< class T >
    inline T range_end(Pair<T> &x)
    {
        return x.last;
    }

    template< class T >
    inline T range_end(const Pair<T> &x)
    {
        return x.last;
    }

} // namespace 'Foo'


//using namespace std;
//using namespace boost::geometry;

//    //
//typedef model::d2::point_xy<double> point_2d;

double NULL_PT = 0.0;

struct pt 
{
	double & ptx ;
	double & pty ;

    /// @brief Default constructor, no initialization
	inline pt(): ptx(NULL_PT), pty(NULL_PT) 
    {}

    /// @brief Constructor to set one, two or three values
	inline pt(double & v0, double & v1) : ptx(v0), pty(v1) 
    {

    }

	inline pt& operator= (pt & rhs)
	{
		//this.ptx = rhs.ptx;
		//this.pty = rhs.pty;
		////return pt(rhs.ptx, rhs.pty);
		//return this;
		return rhs;
	}

	//inline double & getx(){return *ptx;}
	//inline double const & gety(){return *pty;}
	//inline void setx(double &px){ptx = &px;}
	//inline void sety(double &py){pty = &py;}
	inline double const& getx()const {return ptx;}
	inline double const& gety()const {return pty;}
	inline void setx(double const& px){ptx = px;}
	inline void sety(double const& py){pty = py;}
};



namespace bg = boost::geometry;

//BOOST_GEOMETRY_REGISTER_P
//BOOST_GEOMETRY_REGISTER_POINT_2D(pt, double*, bg::cs::cartesian, ptx, pty)
	BOOST_GEOMETRY_REGISTER_POINT_2D_GET_SET(pt, double, bg::cs::cartesian, getx, gety, setx, sety)
//
//
//BOOST_GEOMETRY_REGISTER_RING(vector<point_2d>)
//

//
typedef bg::model::polygon<pt, false, false> polygon;
//typedef bg::model::polygon<bg::model::point<double, 2, bg::cs::cartesian> , false, false> polygon;
//
//template<int n, int m> void assign_polygon(const double (&a)[n][m], polygon *p)
//{
//	assign_points(*p,a);
//};

int main()
{
    double coor[][2] = {
        {0.0, 1.3}, {2.4, 1.7}, {2.1, 1.8}, {1.4, 1.2}
    };

    typedef std::vector<int>::iterator  iter;
    std::vector<int>                    vec(4, 50);
    Foo::Pair<iter>                     pair = { vec.begin(), vec.end() };
	Foo::Pair<double(*)[2]>	newpair = { (double(*)[2]) coor[0], (double(*)[2]) coor[4]  };
    const Foo::Pair<iter>              &cpair = pair;

	double tst[2] = {1.0, 2.0};
	//newpair.first = &tst;

	//BOOST_FOREACH( double *pair, newpair)
	//{
	//	std::cout << pair[1] << " " << pair[2];
	//}

	polygon poly;
	boost::geometry::assign_points(poly, newpair);

	BOOST_FOREACH( pt point, poly.outer() )
	{
		std::cout <<  &point.ptx << " " << &point.pty << std::endl;
	}

	for (unsigned i = 0; i < 3; i++)
	{
		std::cout <<  &coor[i][0] << " " << &coor[i][1] << std::endl;
	}
    //
    // Notice that we call 'begin' etc with qualification.
    //
    iter i = boost::begin(pair);
    iter e = boost::end(pair);
    i      = boost::begin(cpair);
    e      = boost::end(cpair);
    boost::range_difference< Foo::Pair<iter> >::type s = boost::size(pair);
    s      = boost::size(cpair);
    boost::range_reverse_iterator< const Foo::Pair<iter> >::type
    ri     = boost::rbegin(cpair),
    re     = boost::rend(cpair);


    //		        const double coor[][2] = {
    //				{0.0, 1.3}, {2.4, 1.7}, {2.1, 1.8}, {1.4, 1.2}};
    //
    //		const double coor1[][2] = {
    //			{0.0, 0.3}, {2.4, 0}, {2.8, 1.8}, {3.4, 1.2}, {0, 1.6}};
    //			const double coor2[][2] = {
    //				{1.0, 0.5}, {2.0, 0.6}, {2.0, 1.0}};

    //   Engine *ep;

    //   /*
    //    * Call engOpen with a NULL string. This starts a MATLAB process
    //    * on the current host using the command "matlab".
    //    */
    //   if(!(ep = engOpen(""))) {
    //       fprintf(stderr, "\nCan't start MATLAB engine\n");
    //       return EXIT_FAILURE;
    //   }
    //   mxArray *my_ref = mxCreateCellMatrix(1, 2);
    //   mxArray *my_clip = mxCreateCellMatrix(1, 2);

    //   mxArray *mx_array = mxCreateDoubleMatrix(4, 2, mxREAL);

    //		const int num_points = mxGetM(mx_array);
    //		const int point_sz = mxGetN(mx_array);

    //   double *mx_start = mxGetPr(mx_array);
    //   size_t sz = mxGetElementSize(mx_array);

    //polygon mypoly, ppoly;
    //vector<double[2]> p_list;
    //assign(p_list, coor);




    //   for(unsigned i = 0; i < sz; i++) {
    //       mx_start[i] = i;
    //   }

    ////assign_polygon(mx_start, &mypoly);
    ////assign_points(mypoly,*((double(*)[4][2]) mx_start));
    //   printf("m = %d ; n = %d \n", mxGetM(mx_array), mxGetN(mx_array));
    //   printf("elements:\n");
    ////int i = 2;
    //   BOOST_FOREACH(const double el, *(double(*)[2])mx_start) {
    //       printf("%g, ", el);
    //   }
    //   double *pr_test = *(double( *)[8])mx_start;

    //   for(int i=0; i<8; i++) {
    //       printf("%g, ", *(pr_test++));
    //   }

    //   //for (unsigned i = 0; i<mxGetM(mx_array)
    //   //

    //   //using namespace boost::geometry;

    //   //   typedef boost::geometry::model::polygon<boost::geometry::model::d2::point_xy<double> > polygon;

    //   //typedef boost::tuple<double, double> pt;
    //   //typedef std::vector<pt, std::allocator<pt>> lst;
    //   //
    //   //lst pt_lst;
    //   //pt_lst.push_back(boost::make_tuple(0,0));
    //   //pt_lst.push_back(boost::make_tuple(10,0));
    //   //pt_lst.push_back(boost::make_tuple(10,10));
    //   //pt_lst.push_back(boost::make_tuple(0,10));

    //   //	lst.push_back(b);
    //   //	lst.push_back(c);
    //   //    lst.push_back(d);

    //   //typedef std::vector<my_point*> ln;

    //   //ln myline;
    //   //myline.push_back(new my_point(&pt_lst[0].get<0>(), &pt_lst[0].get<1>()));
    //   //myline.push_back(new my_point(&pt_lst[1].get<0>(), &pt_lst[1].get<1>()));
    //   //myline.push_back(new my_point(&pt_lst[2].get<0>(), &pt_lst[2].get<1>()));
    //   //myline.push_back(new my_point(&pt_lst[3].get<0>(), &pt_lst[3].get<1>()));
    //   /*for ( i = 0.0; i < 10.0; i++)
    //   {
    //       my_point* p = new my_point;
    //       p->x = i;
    //       p->y = i + 1;
    //       myline.push_back(p);
    //   }
    //   */
    //   /*
    //       polygon green, blue;

    //       boost::geometry::read_wkt(
    //           "POLYGON((2 1.3,2.4 1.7,2.8 1.8,3.4 1.2,3.7 1.6,3.4 2,4.1 3,5.3 2.6,5.4 1.2,4.9 0.8,2.9 0.7,2 1.3)"
    //               "(4.0 2.0, 4.2 1.4, 4.8 1.9, 4.4 2.2, 4.0 2.0))", green);

    //       boost::geometry::read_wkt(
    //           "POLYGON((4.0 -0.5 , 3.5 1.0 , 2.0 1.5 , 3.5 2.0 , 4.0 3.5 , 4.5 2.0 , 6.0 1.5 , 4.5 1.0 , 4.0 -0.5))", blue);

    //       std::list<polygon> output;
    //       boost::geometry::difference(green, blue, output);

    //       int i = 0;
    //       std::cout << "green - blue:" << std::endl;
    //       BOOST_FOREACH(polygon const& p, output)
    //       {
    //           std::cout << i++ << ": " << boost::geometry::area(p) << std::endl;
    //       }

    //       output.clear();
    //       boost::geometry::difference(blue, green, output);

    //       i = 0;
    //       std::cout << "blue - green:" << std::endl;
    //       BOOST_FOREACH(polygon const& p, output)
    //       {
    //           std::cout << i++ << ": " << boost::geometry::area(p) << std::endl;
    //       }

    //   */
    return 0;
}


