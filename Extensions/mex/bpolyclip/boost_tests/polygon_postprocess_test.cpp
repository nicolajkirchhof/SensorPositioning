// TODO: reference additional headers your program requires here

#include <iostream>
#include <list>

#include "../bpolyclip/spike_removal_nico.hpp"
#include <boost/cstdint.hpp>
#include <boost/geometry.hpp>
#include <boost/geometry/geometries/register/point.hpp>
#include <boost/geometry/geometries/register/ring.hpp>
//#include <boost/geometry/geometries/point_xy.hpp>
#include <boost/geometry/geometries/point.hpp>
#include <boost/geometry/geometries/polygon.hpp>
#include <boost/geometry/geometries/adapted/c_array.hpp>
#include <boost/geometry/extensions/algorithms/mark_spikes.hpp>
#include <boost/geometry/extensions/algorithms/remove_marked.hpp>
//#include <boost/geometry/extensions/contrib/ttmath/ttmath.h>
//#include <boost/geometry/extensions/contrib/ttmath_stub.hpp>
//#include <boost/geometry/extensions/algorithms/remove_spikes.hpp>
//#include <boost/geometry/io/wkt/wkt.hpp>
//#include <boost/tuple/tuple.hpp>
//#include <boost/geometry/geometries/adapted/boost_tuple.hpp>
//#include <boost/range/concepts.hpp>
#include <boost/operators.hpp>
//#include <boost/foreach.hpp>

//#include "generic_range.h"
#include <boost/geometry/multi/geometries/multi_polygon.hpp>
#include <boost/geometry/multi/geometries/register/multi_polygon.hpp>
#include <boost/foreach.hpp>
#include <string>
#include <sstream>


namespace bg = boost::geometry;
//typedef generic_range::Pair<double( *)[2]> bpoly_dbl_points_range_type;
typedef bg::model::point<double, 2, bg::cs::cartesian> bpoly_point_type;
typedef bg::model::polygon<bpoly_point_type, false, true> bpoly_polygon_type;
typedef std::vector<bpoly_polygon_type> bpoly_multipolygon_type;
typedef bg::model::point<int_least64_t, 2, bg::cs::cartesian> bpoly_int_point_type;
typedef bg::model::polygon<bpoly_int_point_type, false, true> bpoly_int_polygon_type;
typedef std::vector<bpoly_int_polygon_type> bpoly_int_multipolygon_type;
BOOST_GEOMETRY_REGISTER_C_ARRAY_CS(cs::cartesian)
//BOOST_GEOMETRY_REGISTER_RING(bpoly_dbl_points_range_type)
BOOST_GEOMETRY_REGISTER_RING(std::vector<bpoly_point_type>)
BOOST_GEOMETRY_REGISTER_MULTI_POLYGON(bpoly_multipolygon_type)

BOOST_GEOMETRY_REGISTER_RING(std::vector<bpoly_int_point_type>)
BOOST_GEOMETRY_REGISTER_MULTI_POLYGON(bpoly_int_multipolygon_type)


enum ClipMethods {
    DIFFERENCE = 0,
    INTERSECTION = 1,
    XOR = 2,
    UNION = 3
};

int main(void)
{
    std::vector<bpoly_polygon_type> polys_fov, polys_vis, polys_out;
    bpoly_polygon_type poly_fov, poly_vis;
    bpoly_multipolygon_type mp_cut, mp_cut2, mp_out, mp_out2;
    std::vector<bpoly_multipolygon_type> mps_out;

    //	bpoly_polygon_type poly_tmp;
    //boost::geometry::read_wkt(
    //"POLYGON((5.999151 13.000000,11.999857 7.000143,12.000000 8.000000,11.000000 8.000000,6.000000 13.000000,5.999151 13.000000))", pp_test);

    std::vector<std::string> strings_fov, strings_vis;
    std::vector<ClipMethods> clips;

    /////////////////////// FOV
    strings_fov.push_back("POLYGON((1.000000 1.000000,7.427000 8.660000,6.735000 9.191000,6.000000 9.660000,5.226000 10.063000,4.420000 10.396000,3.588000 10.659000,2.736000 10.848000,1.871000 10.961000,1.000000 11.000000,0.128000 10.961000,1.000000 1.000000))");
    strings_fov.push_back("POLYGON((11.400000 1.000000,2.739000 5.999000,2.336000 5.226000,2.003000 4.420000,1.740000 3.588000,1.551000 2.736000,1.438000 1.871000,1.400000 0.999000,1.438000 0.128000,1.551000 -0.737000,1.740000 -1.589000,11.400000 1.000000))");
    strings_fov.push_back("POLYGON((12.000000 5.000000,12.000000 15.000000,11.128000 14.961000,10.263000 14.848000,9.411000 14.659000,8.579000 14.396000,7.773000 14.063000,7.000000 13.660000,6.264000 13.191000,5.572000 12.660000,4.928000 12.071000,12.000000 5.000000))");
    strings_fov.push_back("POLYGON((1.000000 1.000000,11.000000 1.000000,10.961000 1.871000,10.848000 2.736000,10.659000 3.588000,10.396000 4.420000,10.063000 5.226000,9.660000 5.999000,9.191000 6.735000,8.660000 7.427000,8.071000 8.071000,1.000000 1.000000))");
	//strings_fov.push_back("POLYGON((17.000000 15.368421,8.999999 8.000000,8.536188 8.000000,9.060444 7.427876,9.591520 6.735764,10.060254 5.999999,1.400000 1.000000,3.275644 7.999999,8.536188 8.000000,8.471067 8.071067,7.827876 8.660444,7.135764 9.191520,6.400000 9.660254,5.626182 10.063077,4.820201 10.396926,3.988190 10.659258,3.275644 7.999999,1.000000 7.999999,1.000000 1.000000,12.000000 1.000000,12.000000 8.000000,11.000000 8.000000,11.000000 9.000000,17.000000 14.000000,17.000000 15.368421))");
	strings_fov.push_back("POLYGON((1.000000 1.727940,1.000000 1.000000,3.000000 1.000000,1.000000 1.727940))");
	strings_fov.push_back("POLYGON((0.99989601003898410000 1.72792972711149040000,1.00000000000000000000 1.00000000000000000000,3.00000000000000000000 1.00000000000000000000,0.99989601003898410000 1.72792972711149040000))");
	strings_fov.push_back("POLYGON((0.99989601003898410000 1.72792972711149040000,1.00000000000000000000 1.00000000000000000000,3.00000000000000000000 1.00000000000000000000))");
	strings_fov.push_back("POLYGON((1000 1728,1000 1000,3000 1000,1000 1728))");
		
    ////////////////////// VIS
    strings_vis.push_back("POLYGON((1.000000 1.000000,12.000000 1.000000,12.000000 8.000000,11.000000 7.999000,11.000000 9.000000,17.000000 13.799000,17.000000 15.000000,9.000000 8.000000,1.000000 8.000000,1.000000 1.000000))");
    strings_vis.push_back("POLYGON((1.000000 1.000000,12.000000 1.000000,12.000000 8.000000,11.000000 8.000000,10.257000 21.000000,9.844000 21.000000,10.000000 16.000000,8.630000 16.000000,9.000000 13.999000,9.000000 13.000000,7.799000 13.000000,9.000000 9.000000,9.000000 8.000000,1.000000 8.000000,1.000000 1.000000))");
    strings_vis.push_back("POLYGON((0.999000 1.000000,12.000000 1.000000,12.000000 8.000000,11.000000 8.000000,8.999000 14.000000,9.000000 13.000000,6.000000 13.000000,9.000000 9.000000,9.000000 8.000000,1.000000 8.000000,0.999000 1.000000))");
    strings_vis.push_back("POLYGON((1.000000 1.000000,12.000000 1.000000,12.000000 8.000000,11.000000 7.999000,11.000000 9.000000,17.000000 13.799000,17.000000 15.000000,9.000000 8.000000,1.000000 8.000000,1.000000 1.000000))");

	strings_vis.push_back("POLYGON((0.999896 1.727930,1.000000 1.000000,3.000000 1.000000,0.999896 1.727930))");
	strings_vis.push_back("POLYGON((1.00000000000000000000 1.72794046853240510000,1.00000000000000020000 1.00000000000000020000,2.99999999999999960000 1.00000000000000020000,1.00000000000000000000 1.72794046853240510000))");
	strings_vis.push_back("POLYGON((1.00000000000000000000 1.72794046853240510000,1.00000000000000000000 1.00000000000000020000,2.99999999999999960000 1.00000000000000020000))");
	strings_vis.push_back("POLYGON((1000 1728,1000 1000,3000 1000,1000 1728))");
    //////////////////// CT (( > >, = >, < >, > > ))
    clips.push_back(INTERSECTION);
    clips.push_back(UNION);
    clips.push_back(DIFFERENCE);
    clips.push_back(DIFFERENCE);
	clips.push_back(UNION);
	clips.push_back(UNION);
	clips.push_back(UNION);

    bg::remove_by_normalized_nico<bpoly_point_type> spike_policy_nico(1e-2);

	//typedef bg::model::point<ttmath_big, 2, bg::cs::cartesian> bpoly_tt_point_type;
 //   typedef bg::model::polygon<bpoly_tt_point_type, false, true> bpoly_tt_polygon_type;
 //   typedef std::vector<bpoly_tt_polygon_type> bpoly_tt_multipolygon_type;

	////BOOST_GEOMETRY_REGISTER_RING(std::vector<bpoly_tt_point_type>);
	////BOOST_GEOMETRY_REGISTER_MULTI_POLYGON(bpoly_tt_multipolygon_type);

    bpoly_int_polygon_type int_fov, int_vis;
    bpoly_int_multipolygon_type int_cut;

	boost::geometry::read_wkt(strings_vis[7], int_fov);
    boost::geometry::read_wkt(strings_fov[7], int_vis);

	bg::sym_difference(int_vis, int_fov, int_cut);

	        //boost::geometry::read_wkt(strings_vis[5], poly_vis);
        //boost::geometry::read_wkt(strings_fov[5], poly_fov);
		

    for(int i = 4; i<strings_fov.size(); i++) {
        boost::geometry::read_wkt(strings_vis[i], poly_vis);
        boost::geometry::read_wkt(strings_fov[i], poly_fov);

		 

	//		std::cout << bg::dsv(poly_vis) << std::endl;
	//std::cout << bg::dsv(poly_fov) << std::endl;
	//bg::correct(poly_vis);
	//bg::correct(poly_fov);
	//std::cout << bg::dsv(poly_vis) << std::endl;
	//std::cout << bg::dsv(poly_fov) << std::endl;

        switch(clips[i]) {
            case DIFFERENCE: {
                /*
*/
                bg::difference(poly_vis, poly_fov, mp_cut);
				bg::difference(poly_fov, poly_vis, mp_cut2);
                //bg::difference(tt_vis, tt_fov, tt_cut);
                break;
            }

            case INTERSECTION: {
                bg::intersection(poly_vis, poly_fov, mp_cut);
                break;
            }

            case XOR: {
                bg::sym_difference(poly_vis, poly_fov, mp_cut);
				bg::sym_difference(poly_fov, poly_vis, mp_cut2);
                break;
            }

            case UNION: {
                bg::union_(poly_vis, poly_fov, mp_cut);
                break;
            }

            default
                    : {
                    std::cout << " no such Type ";
                }
        }


		std::cout << bg::dsv(mp_cut) << std::endl;
        bg::remove_spikes(mp_cut, mp_out, spike_policy_nico);
        std::cout << bg::dsv(mp_out) << std::endl;

		double area_out = bg::area(mp_out);
		double area_vis = bg::area(poly_vis);
		double area_fov = bg::area(poly_fov);

		if (std::abs(area_out - area_vis) < 1e-1 && std::abs(area_vis - area_fov) < 1e-1)
			std::cout << "EQUAL" << std::endl;

        //std::cout << bg::dsv(mp_cut2) << std::endl;
        //bg::remove_spikes(mp_cut2, mp_out2, spike_policy_nico);
        //std::cout << bg::dsv(mp_out2) << std::endl;

        polys_vis.push_back(poly_vis);
        polys_fov.push_back(poly_fov);
        mps_out.push_back(mp_out);
        bg::clear(mp_out);
        bg::clear(poly_vis);
        bg::clear(poly_fov);

    }

    //
    //bg::union_(pp_vis2, pp_fov2, mp_out2);
    //bg::intersection(pp_vis, pp_fov, mp_out);
    //
    //	//mp_test.push_back(pp_test);
    //	bg::simplify<bpoly_polygon_type, double>(pp_test, pp_sim, 1e-2);
    //
    //	std::cout << bg::touches<bpoly_polygon_type>(pp_test) << std::endl;
    //	std::cout << bg::touches<bpoly_polygon_type>(pp_sim) << std::endl;
    //
    //
    //
    //
    //	std::map<bg::ring_identifier, std::vector<bool> > mark_map;
    //	bg::select_gapped_spike<> mark_spike_policy(0.01, 0.01);
    //
    //	bg::mark_spikes(pp_test, mark_map, mark_spike_policy);
    //	//bg::remove_marked
    //
    //
    //
    //
    //	typedef bg::remove_by_normalized_nico<bpoly_point_type> spike_policy;
    //	spike_policy spike_policy_nico(1e-2);
    ////bg::remove_by_normalized<bpoly_point_type> spike_policy(1e-2);
    //	//bg::remove_spikes(pp_test, spike_policy_nico);
    //
    //	std::cout << bg::dsv(mp_out2) << std::endl;
    //	bg::remove_spikes<bpoly_multipolygon_type, bpoly_multipolygon_type, spike_policy> (mp_out2, mp_nospike2, spike_policy_nico);
    //	std::cout << bg::dsv(mp_nospike2) << std::endl;
    //	std::cout << bg::dsv(mp_out) << std::endl;
    //	bg::remove_spikes(mp_out, mp_nospike, spike_policy_nico);
    //	std::cout << bg::dsv(mp_nospike) << std::endl;
    //

    //if (touch == touch_sim)
    //std::cout << "touch same";

    //test_difference_parcel_precision<float>();
    //test_difference_parcel_precision<double>();
    //test_difference_parcel_precision<ttmath_big>();


    return 0;

}

