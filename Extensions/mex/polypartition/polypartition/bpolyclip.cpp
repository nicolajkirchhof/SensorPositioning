#include "bpolyclip.hpp"

void mexFunction(int nlhs, mxArray *plhs[],
                           int nrhs, const mxArray *prhs[])
{
	bpolyclip::bpolyclip(nlhs, plhs, nrhs, prhs);
}

///**************************************************************************************
// * MATLAB MEX LIBRARY bpolyclip_lib.dll
// *
// * EXPORTS:
// *  void bpolyclip(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
// *   whereas prhs = (ref_poly, clip_poly, method, check, pt_merge_dist, spike_diameter)
// *
// * PURPOSE: engine to compute boolean operations on two polygons
// *
// *  INPUTS:
// *  ref_poly, clip_poly = [chooseable, INT64 or DOUBLE supported]
// *          ring [2 n],
// *          polygon {[2 n], [...]}
// *          multi_polygon {{[2 n], [...]}{...}}
// *
// *  method  = [int]
// *          0 - Difference (RefPol - ClipPol)
// *          1 - Intersection (Default)
// *          2 - Xor
// *          3 - Union
// *  check   = [bool] should the input arguments be checked
// *  pt_merge_dist   = [double] point merge distance
// *  spike_diameter  = [double] spikes with < lower then this bound will be removed
// *
// *  OUTPUTS:
// *  prhs {{[2 n], [...]}{...}}
// *
// * Compilation:
// *  TO BE DONE
// *  >> mex -O -v insidepoly_dblengine.c
// *  (add -largeArrayDims mex option on 64-bit computer)
// * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
// * History
// *  Original: 19-Dec-2012
// **************************************************************************************/
//#include "stdafx.h"
//
//#define LIBRARY_EXPORTS
//#include "bpolyclip_lib.hpp"
//
//#include "generic_range.hpp"
//#include "spike_removal_nico.hpp"
//
////#define DllExport   __declspec( dllexport )
//#define REF_POLY 0
//#define CLIP_POLY 1
//#define METHOD 2
//#define CHECK 3
//#define PT_MERGE_DIST 4
//#define SPIKE_DIAMETER 5
//
//namespace bg = boost::geometry;
//
//BOOST_GEOMETRY_REGISTER_C_ARRAY_CS(cs::cartesian)
//
//typedef generic_range::Pair<double( *)[2]> bpoly_dbl_points_range_type;
//typedef generic_range::Pair<int_least64_t( *)[2]> bpoly_int_points_range_type;
//BOOST_GEOMETRY_REGISTER_RING(bpoly_dbl_points_range_type)
//BOOST_GEOMETRY_REGISTER_RING(bpoly_int_points_range_type)
//
//typedef bg::model::point<double, 2, bg::cs::cartesian> bpoly_dbl_point_type;
//typedef bg::model::polygon<bpoly_dbl_point_type, false, true> bpoly_dbl_polygon_type;
//typedef std::vector<bpoly_dbl_polygon_type> bpoly_dbl_multipolygon_type;
//
//typedef bg::model::point<int_least64_t, 2, bg::cs::cartesian> bpoly_int_point_type;
//typedef bg::model::polygon<bpoly_int_point_type, false, true> bpoly_int_polygon_type;
//typedef std::vector<bpoly_int_polygon_type> bpoly_int_multipolygon_type;
//
//
//BOOST_GEOMETRY_REGISTER_RING(std::vector<bpoly_dbl_point_type>)
//BOOST_GEOMETRY_REGISTER_MULTI_POLYGON(bpoly_dbl_multipolygon_type)
//
//BOOST_GEOMETRY_REGISTER_RING(std::vector<bpoly_int_point_type>)
//BOOST_GEOMETRY_REGISTER_MULTI_POLYGON(bpoly_int_multipolygon_type)
//
//namespace bpolyclip_lib {
//
//void output_usage()
//{
//    mexPrintf(
//        "**************************************************************************************\n"
//        "* MATLAB MEX LIBRARY bpolyclip_lib.dll												   \n"
//        "*																					   \n"
//        "* EXPORTS:																			   \n"
//        "*  void bpolyclip(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])	   \n"
//        "*   whereas prhs = (ref_poly, clip_poly, method, check, pt_merge_dist, spike_diameter)\n"
//        "*  																				   \n"
//        "* PURPOSE: engine to compute boolean operations on two polygons					   \n"
//        "*																					   \n"
//        "*  INPUTS:																			   \n"
//        "*  ref_poly, clip_poly	= [chooseable, INT64 or DOUBLE supported]					   \n"
//        "*			ring [2 n], 															   \n"
//        "*			polygon {[2 n], [...]} 													   \n"
//        "*			multi_polygon {{[2 n], [...]}{...}} 									   \n"
//        "*																					   \n"
//        "* 	method	= [int]																	   \n"
//        "*			0 - Difference (RefPol - ClipPol)     									   \n"
//        "*			1 - Intersection (Default)												   \n"
//        "*			2 - Xor																	   \n"
//        "*			3 - Union																   \n"
//        "*  check	= [bool] should the input arguments be checked							   \n"
//        "*	spike_diameter	= [double] spikes with < lower then this bound will be removed	   \n"
//        "*	pt_merge_dist	= [double] point merge distance									   \n"
//        "* 																					   \n"
//        "*  OUTPUTS:																		   \n"
//        "*  prhs {{[2 n], [...]}{...}}														   \n"
//        "*																					   \n"
//        "* Compilation:																		   \n"
//        "* 	TO BE DONE																		   \n"
//        "*  >> mex -O -v insidepoly_dblengine.c												   \n"
//        "*  (add -largeArrayDims mex option on 64-bit computer)								   \n"
//        "* Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>							   \n"
//        "* History																			   \n"
//        "*  Original: 19-Dec-2012															   \n"
//        "**************************************************************************************\n"
//    );
//}
//
//enum ClipMethods {
//    DIFFERENCE = 0,
//    INTERSECTION = 1,
//    XOR = 2,
//    UNION = 3
//};
//
//LIBRARY_API struct bpolyclip_options {
//    bpolyclip_options() : clip_method(INTERSECTION), test_input(false), spike_diameter(0.0), spike_distance(0.0)
//    {};
//    ClipMethods clip_method;
//    bool test_input;
//    double spike_diameter;
//    double spike_distance;
//    // check for given format
//    mxClassID id;
//};
//
//template< typename ValueType>
//generic_range::Pair<ValueType( *)[2]> read_ring(mxArray const &mx_array)
//{
//    typedef generic_range::Pair<ValueType( *)[2]> bpoly_ring_type;
//    //std::ostringstream err;
//
//    size_t num_points = mxGetN(&mx_array);
//    size_t point_sz = mxGetM(&mx_array);
//
//    // check size
//    if(point_sz != 2) {
//        mexErrMsgTxt("Point size is not [n 2] for ");
//    };
//
//    ValueType(*array_ptr)[2]  = (ValueType( *)[2]) mxGetPr(&mx_array);
//
//    bpoly_ring_type ring_out = {&array_ptr[0] ,  &array_ptr[num_points]};
//
//    return ring_out;
//}
//
//template< typename ValueType, typename PolygonType >
//void read_polygon(mxArray const &mx_array, PolygonType &mpoly_out)
//{
//    // check if ring is given
//    if ( !mxIsCell(&mx_array) ) {
//        // since -1 is the outer ring...
//        bg::append(mpoly_out, read_ring<ValueType> (mx_array), -1);
//        return;
//    }
//
//    // we do not care for column or row vector of polygon rings
//    size_t sz = mxGetM(&mx_array) > mxGetN(&mx_array) ? mxGetM(&mx_array) : mxGetN(&mx_array);
//
//    // we have to check if we given multiple cells or just [n 2] array for outer hull
//    if(sz > 1) {
//        mpoly_out.inners().resize(sz - 1);
//    }
//
//    for(int idx_t = 0; idx_t < sz; idx_t++) {
//        const mxArray *bpoly_polygon_type_ptr = mxGetCell(&mx_array, idx_t);
//
//        // since -1 is the outer ring...
//        bg::append(mpoly_out, read_ring<ValueType> (*bpoly_polygon_type_ptr), idx_t - 1);
//    }
//
//}
//
//template< typename ValueType, typename MultiPolygonType, typename PolygonType>
//void read_multipolygon(mxArray const &mx_array, MultiPolygonType &mmpoly_out)
//{
//    // check if ring or polygon is given
//    if (!mxIsCell(&mx_array) || mxIsCell(mxGetCell(&mx_array, 0))) {
//        mmpoly_out.resize(1);
//        read_polygon<ValueType, PolygonType> (mx_array, mmpoly_out[0]);
//        return;
//    }
//
//    // we do not care for column or row vector of multi_polygon
//    size_t sz = mxGetM(&mx_array) > mxGetN(&mx_array) ? mxGetM(&mx_array) : mxGetN(&mx_array);
//
//    // check if multi_poly is empty (size == 0)
//    if (sz == 0) { return; }
//
//    // resize to num of polygons
//    mmpoly_out.resize(sz);
//
//    for(unsigned idp = 0; idp < sz; ++idp) {
//        read_polygon<ValueType, PolygonType>(*mxGetCell(&mx_array, idp), mmpoly_out[idp]);
//    }
//}
//
//template<typename ValueType>
//struct bpoly_types {
//    //std::vector<bg::model::polygon<bg::model::point<ValueType, 2, bg::cs::cartesian>, false, true>> Type;
//    typedef bg::model::point<ValueType, 2, bg::cs::cartesian> bpoly_point_type;
//    typedef bg::model::polygon<bpoly_point_type, false, true> bpoly_polygon_type;
//    typedef std::vector<bpoly_polygon_type> bpoly_multipolygon_type;
//};
//
//
//LIBRARY_API template<typename ValueType> 
//void clip_multipolygon(typename bpoly_types<ValueType>::bpoly_multipolygon_type const &poly_ref , typename bpoly_types<ValueType>::bpoly_multipolygon_type const &poly_clip, typename bpoly_types<ValueType>::bpoly_multipolygon_type &poly_out, bpolyclip_options const &bpo)
//{
//	// make temp poly
//	bpoly_types<ValueType>::bpoly_multipolygon_type poly_cut;
//    // test and correct input if wanted
//    if(bpo.test_input) {
//        if(bg::intersects(poly_ref) || bg::intersects(poly_clip) || bg::touches(poly_ref) || bg::touches(poly_clip)) {
//            plhs[0] = mxCreateDoubleScalar(mxGetNaN());
//            mexWarnMsgTxt("Output is invalid, since one of the polygons is either self-intersecting or self-touching");
//            return;
//        }
//
//        bg::correct(poly_ref);
//        bg::correct(poly_clip);
//    }
//
//    switch(bpo.clip_method) {
//        case DIFFERENCE: {
//            bg::difference(poly_ref, poly_clip, poly_cut);
//            break;
//        }
//
//        case INTERSECTION: {
//            bg::intersection(poly_ref, poly_clip, poly_cut);
//            break;
//        }
//
//        case XOR: {
//            bg::sym_difference(poly_ref, poly_clip, poly_cut);
//            break;
//        }
//
//        case UNION: {
//            bg::union_(poly_ref, poly_clip, poly_cut);
//            break;
//        }
//
//        default
//                : {
//                mexErrMsgTxt(" no such Type ");
//            }
//    }
//
//    if(bpo.spike_diameter > 0) {
//        bg::remove_by_normalized_nico<bpoly_point_type> spike_policy_nico((ValueType)bpo.spike_diameter);
//        bg::remove_spikes(poly_cut, mpoly_out, spike_policy_nico);
//    } else
//    { &mpoly_out = &poly_cut; }
//}
//
//
//template<typename ValueType>
//void clip_matlab_input(const int nlhs,  mxArray *plhs[], const int nrhs, const mxArray *prhs[], bpolyclip_options const &bpo)
//{
//    // define geometry types, note: types must be predefined in header!!!
//    typedef bg::model::point<ValueType, 2, bg::cs::cartesian> bpoly_point_type;
//    typedef bg::model::polygon<bpoly_point_type, false, true> bpoly_polygon_type;
//    typedef std::vector<bpoly_polygon_type> bpoly_multipolygon_type;
//
//    bpoly_multipolygon_type poly_ref, poly_clip, mpoly_out;
//    read_multipolygon<ValueType, bpoly_multipolygon_type, bpoly_polygon_type>(*prhs[0], poly_ref);
//    read_multipolygon<ValueType, bpoly_multipolygon_type, bpoly_polygon_type>(*prhs[1], poly_clip);
//
//    // write polygon to output
//    mxArray *mpoly_out_matlab = mxCreateCellMatrix(1, mpoly_out.size());
//
//    for(int idmp = 0; idmp < mpoly_out.size(); ++idmp) {
//        // create cell for poly. (+1 for outer ring)
//        size_t num_interior_rings = bg::num_interior_rings(mpoly_out[idmp]);
//        mxArray *poly_out_matlab = mxCreateCellMatrix(1, num_interior_rings + 1);
//
//        // assign outer ring
//        size_t num_points = bg::num_points(mpoly_out[idmp].outer());
//
//        mxArray *points_out_matlab = mxCreateNumericMatrix(2, num_points, bpo.id, mxREAL);
//        ValueType(*ml_array_ptr)[2]  = (ValueType( *)[2]) mxGetPr(points_out_matlab);
//
//        for(int idmla = 0; idmla < num_points; ++idmla) {
//            ml_array_ptr[idmla][0] = mpoly_out[idmp].outer()[idmla].get<0>();
//            ml_array_ptr[idmla][1] = mpoly_out[idmp].outer()[idmla].get<1>();
//        }
//
//        mxSetCell(poly_out_matlab, 0, points_out_matlab);
//
//        // export rings
//        for(int idrng = 0; idrng < num_interior_rings; ++idrng) {
//
//            num_points = bg::num_points(mpoly_out[idmp].inners()[idrng]);
//            mxArray *points_out_matlab = mxCreateNumericMatrix(2, num_points, bpo.id, mxREAL);
//            ValueType(*ml_array_ptr)[2]  = (ValueType( *)[2]) mxGetPr(points_out_matlab);
//
//            for(int idmla = 0; idmla < num_points; ++idmla) {
//                ml_array_ptr[idmla][0] = mpoly_out[idmp].inners()[idrng][idmla].get<0>();
//                ml_array_ptr[idmla][1] = mpoly_out[idmp].inners()[idrng][idmla].get<1>();
//            }
//
//            mxSetCell(poly_out_matlab, idrng + 1, points_out_matlab);
//        }
//
//        mxSetCell(mpoly_out_matlab, idmp, poly_out_matlab);
//    }
//
//    plhs[0] = mpoly_out_matlab;
//
//    if (nlhs > 1) {
//        double area = (double)bg::area(mpoly_out);
//        plhs[1] = mxCreateDoubleScalar(area);
//    }
//}
//
////=========================Exported=========================//
//LIBRARY_API void bpolyclip(int &nlhs, mxArray *plhs[],
//                           int &nrhs, const mxArray *prhs[])
//{
//
//    // check input size
//    if((nrhs < 2) || (nrhs > 6)) {
//        output_usage();
//        return;
//    }
//
//    std::ostringstream err;
//    bpolyclip_options bpo;
//
//    //  check if clip type type was given and assigned
//    if(nrhs >= 3) {
//        int ct = (int)mxGetScalar(prhs[2]);
//
//        if((ct >= 0) && (ct < 4))
//        { bpo.clip_method = ClipMethods(ct); }
//        else
//        { mexErrMsgTxt("Cliptype is not in Range [0..3]"); }
//
//        if(nrhs >= 4) {
//            bpo.test_input = mxGetScalar(prhs[3]) > 0;
//
//            if(nrhs >= 5) {
//                bpo.spike_diameter = mxGetScalar(prhs[4]);
//
//                if(nrhs >= 6) {
//                    bpo.spike_distance = mxGetScalar(prhs[5]);
//                }
//            }
//        }
//    }
//
//    const mxArray *p_clip = prhs[CLIP_POLY];
//    const mxArray *p_ref = prhs[REF_POLY];
//
//    // fast lane, check if one of the polygons is empty
//    if (mxIsEmpty(p_ref)) {
//        if(bpo.clip_method == INTERSECTION || bpo.clip_method == DIFFERENCE) { plhs[0] = mxCreateCellMatrix(1, 1); }
//        else { plhs[0] = mxDuplicateArray(p_clip); }
//
//        return;
//    } else if (mxIsEmpty(p_clip)) {
//        if(bpo.clip_method == INTERSECTION) { plhs[0] = mxCreateCellMatrix(1, 1); }
//        else { plhs[0] = mxDuplicateArray(p_ref); }
//
//        return;
//    }
//    // if polygons are not empty unpack and check type
//    else {
//        while(mxIsCell(p_ref)) { p_ref = mxGetCell(p_ref, 0); }
//
//        bpo.id = mxGetClassID(p_ref);
//    }
//
//    switch(bpo.id) {
//
//        case mxDOUBLE_CLASS: {
//            clip_matlab_input< double >(nlhs, plhs, nrhs, prhs, bpo);
//        }
//        break;
//
//        case mxINT64_CLASS: {
//            clip_matlab_input< int_least64_t >(nlhs, plhs, nrhs, prhs, bpo);
//        }
//        break;
//
//        default
//                : {
//                err << "Format " << bpo.id << " is not supported";
//                mexErrMsgTxt(err.str().c_str());
//            }
//    }
//
//}
//
//
//
//};
