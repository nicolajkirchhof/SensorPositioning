/**************************************************************************************
 * MATLAB MEX LIBRARY bpolyclip_lib.dll
 *
 * EXPORTS:
 *  void bpolyclip(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
 *   whereas prhs = (ref_poly, clip_poly, method, check, pt_merge_dist, spike_diameter)
 *
 * PURPOSE: engine to compute boolean operations on two polygons
 *
 *  INPUTS:
 *  ref_poly, clip_poly = [chooseable, INT64 or DOUBLE supported]
 *          ring [2 n],
 *          polygon {[2 n], [...]}
 *          multi_polygon {{[2 n], [...]}{...}}
 *
 *  method  = [int]
 *          0 - Difference (RefPol - ClipPol)
 *          1 - Intersection (Default)
 *          2 - Xor
 *          3 - Union
 *  check   = [bool = false] should the input arguments be checked
 *  spike_diameter  = [double = 0] spikes with < lower then this bound will be removed
 *  grid_limit  = [double = 0] self touchings will be moved inside using this grid size
 *
 *  OUTPUTS:
 *  prhs {{[2 n], [...]}{...}}
 * Compilation:
 *  TO BE DONE
 * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
 * History
 *  Original: 19-Dec-2012
 **************************************************************************************/

//#ifdef LIBRARY_EXPORTS
//#    define LIBRARY_API __declspec(dllexport)
//#else
//#    define LIBRARY_API __declspec(dllimport)
//#endif

#include "stdafx.h"
#pragma once

namespace bg = boost::geometry;

BOOST_GEOMETRY_REGISTER_C_ARRAY_CS(cs::cartesian)

typedef generic_range::Pair<double( *)[2]> bpoly_dbl_points_range_type;
typedef generic_range::Pair<int_least64_t( *)[2]> bpoly_int_points_range_type;
BOOST_GEOMETRY_REGISTER_RING(bpoly_dbl_points_range_type)
BOOST_GEOMETRY_REGISTER_RING(bpoly_int_points_range_type)

typedef bg::model::point<double, 2, bg::cs::cartesian> bpoly_dbl_point_type;
typedef bg::model::polygon<bpoly_dbl_point_type, false, true> bpoly_dbl_polygon_type;
typedef std::vector<bpoly_dbl_polygon_type> bpoly_dbl_multipolygon_type;

typedef bg::model::point<int_least64_t, 2, bg::cs::cartesian> bpoly_int_point_type;
typedef bg::model::polygon<bpoly_int_point_type, false, true> bpoly_int_polygon_type;
typedef std::vector<bpoly_int_polygon_type> bpoly_int_multipolygon_type;


BOOST_GEOMETRY_REGISTER_RING(std::vector<bpoly_dbl_point_type>)
BOOST_GEOMETRY_REGISTER_MULTI_POLYGON(bpoly_dbl_multipolygon_type)

BOOST_GEOMETRY_REGISTER_RING(std::vector<bpoly_int_point_type>)
BOOST_GEOMETRY_REGISTER_MULTI_POLYGON(bpoly_int_multipolygon_type)

namespace bpolyclip {

#ifndef NO_MATLAB
void output_usage()
{
    mexPrintf(
        "/**************************************************************************************    \n"
        " * MATLAB MEX LIBRARY bpolyclip_lib.dll                                                    \n"
        " *                                                                                         \n"
        " * EXPORTS:                                                                                \n"
        " *  void bpolyclip(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])         \n"
        " *   whereas prhs = (ref_poly, clip_poly, method, check, pt_merge_dist, spike_diameter)    \n"
        " *                                                                                         \n"
        " * PURPOSE: engine to compute boolean operations on two polygons                           \n"
        " *                                                                                         \n"
        " *  INPUTS:                                                                                \n"
        " *  ref_poly, clip_poly = [chooseable, INT64 or DOUBLE supported]                          \n"
        " *          ring [2 n],                                                                    \n"
        " *          polygon {[2 n], [...]}                                                         \n"
        " *          multi_polygon {{[2 n], [...]}{...}}                                            \n"
        " *                                                                                         \n"
        " *  method  = [int]                                                                        \n"
        " *          0 - Difference (RefPol - ClipPol)                                              \n"
        " *          1 - Intersection (Default)                                                     \n"
        " *          2 - Xor                                                                        \n"
        " *          3 - Union                                                                      \n"
        " *  check   = [bool = false] should the input arguments be checked                         \n"
        " *  spike_diameter  = [double = 0] spikes with < lower then this bound will be removed     \n"
        " *  grid_limit  = [double = 0] self touchings will be moved inside using this grid size \n"
        " *                                                                                         \n"
        " *  OUTPUTS:                                                                               \n"
        " *  prhs {{[2 n], [...]}{...}}                                                             \n"
        " * Compilation:                                                                            \n"
        " *  TO BE DONE                                                                             \n"
        " * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>                                   \n"
        " * History                                                                                 \n"
        " *  Original: 19-Dec-2012                                                                  \n"
        " **************************************************************************************/   \n"
    );
}
#endif

std::ostringstream err;

namespace fn_prhs {
enum names {
    REF_POLY       = 0,
    CLIP_POLY      = 1,
    METHOD         = 2,
    CHECK          = 3,
    SPIKE_DIAMETER  = 4,
    GRID_LIMIT  = 5,
};
}


enum ClipMethods {
    UNKNOWN_METHOD = -1,
    DIFFERENCE = 0,
    INTERSECTION = 1,
    XOR = 2,
    UNION = 3
};

struct bpolyclip_options {
    bpolyclip_options() : clip_method(INTERSECTION), correct(false), spike_diameter(0.0), grid_limit(0.0)
    {};
    ClipMethods clip_method;
    bool correct;
    double spike_diameter;
    double grid_limit;
    // check for given format
#ifndef NO_MATLAB
    mxClassID id;
#endif
};

template<typename ValueType>
struct bpoly_types {
    //std::vector<bg::model::polygon<bg::model::point<ValueType, 2, bg::cs::cartesian>, false, true>> Type;
    typedef bg::model::point<ValueType, 2, bg::cs::cartesian> point_type;
    typedef bg::model::polygon<point_type, false, true> polygon_type;
    typedef std::vector<polygon_type> multipolygon_type;
    typedef generic_range::Pair<ValueType( *)[2]> ring_type;
};

int mod (int const &a, int const &b)
{
    //if(b < 0) //you can check for b == 0 separately and do what you want
    //  return mod(-a, -b);
    int ret = a % b;

    if(ret < 0)
    { ret += b; }

    return ret;
}

#ifndef NO_MATLAB
template< typename ValueType>
typename bpoly_types<ValueType>::ring_type read_ring(mxArray const *mx_array)
{
    typedef generic_range::Pair<ValueType( *)[2]> bpoly_ring_type;
    //std::ostringstream err;
    size_t num_points = mxGetN(mx_array);
    size_t point_sz = mxGetM(mx_array);

    // check size
    if(point_sz != 2) {
        mexErrMsgTxt("Point size is not [2 n] for ");
    };

    ValueType(*array_ptr)[2]  = (ValueType( *)[2]) mxGetPr(mx_array);

    bpoly_ring_type ring_out = {&array_ptr[0] ,  &array_ptr[num_points]};

    return ring_out;
}

template< typename ValueType >
void read_polygon(mxArray const *mx_array, typename bpoly_types<ValueType>::polygon_type &poly_out)
{
    // check if ring is given
    if ( !mxIsCell(mx_array) ) {
        // since -1 is the outer ring...
        bg::append(poly_out, read_ring<ValueType> (mx_array), -1);
        return;
    }

    // we do not care for column or row vector of polygon rings
    size_t sz = mxGetM(mx_array) > mxGetN(mx_array) ? mxGetM(mx_array) : mxGetN(mx_array);

    // we have to check if we given multiple cells or just [n 2] array for outer hull
    if(sz > 1) {
        poly_out.inners().resize(sz - 1);
    }

    for(int idx_t = 0; idx_t < sz; idx_t++) {
        const mxArray *polygon_type_ptr = mxGetCell(mx_array, idx_t);
        // since -1 is the outer ring...
        bg::append(poly_out, read_ring<ValueType> (polygon_type_ptr), idx_t - 1);
    }
}

template< typename ValueType >
void read_multipolygon(mxArray const *mx_array, typename bpoly_types<ValueType>::multipolygon_type &mpoly_out, bpolyclip_options const &bpo)
{
    // check if ring or polygon is given
    if (!mxIsCell(mx_array) || !mxIsCell(mxGetCell(mx_array, 0))) {
        mpoly_out.resize(1);
        read_polygon<ValueType> (mx_array, mpoly_out[0]);
    } else {
        // we do not care for column or row vector of multi_polygon
        size_t sz = mxGetM(mx_array) > mxGetN(mx_array) ? mxGetM(mx_array) : mxGetN(mx_array);

        // check if multi_poly is empty (size == 0)
        if (sz == 0) { return; }

        // resize to num of polygons
        mpoly_out.resize(sz);

        for(unsigned idp = 0; idp < sz; ++idp) {
            read_polygon<ValueType>(mxGetCell(mx_array, idp), mpoly_out[idp]);
        }
    }

    if(bpo.correct) {
        bg::correct(mpoly_out);

        if(bg::touches(mpoly_out) || bg::intersects(mpoly_out)) {
            if(bpo.grid_limit > 0) {
                err << "Polygon is self intersecting or self touching...  correcting";
                mexPrintf(err.str().c_str());
                correct_multipolygon<ValueType> (mpoly_out, bpo);
            } else {
                err << "Polygon is self intersecting or self touching";
                mexErrMsgTxt(err.str().c_str());
                return;
            }
        }
    }
}

//template< typename ValueType >
//void read_multipolygon(mxArray const *mx_array, typename bpoly_types<ValueType>::multipolygon_type &mpoly_out)
//{
//    read_multipolygon<ValueType>(mx_array, mpoly_out, false);
//}

template< typename ValueType >
mxArray *write_multipolygon(typename bpoly_types<ValueType>::multipolygon_type const &poly_out, mxClassID const &id )
{
    // write polygon to output
    mxArray *mpoly_out_matlab = mxCreateCellMatrix(1, poly_out.size());

    for(int idmp = 0; idmp < poly_out.size(); ++idmp) {
        // create cell for poly. (+1 for outer ring)
        size_t num_interior_rings = bg::num_interior_rings(poly_out[idmp]);
        mxArray *poly_out_matlab = mxCreateCellMatrix(1, num_interior_rings + 1);
        // assign outer ring
        size_t num_points = bg::num_points(poly_out[idmp].outer());
        mxArray *points_out_matlab = mxCreateNumericMatrix(2, num_points, id, mxREAL);
        ValueType(*ml_array_ptr)[2]  = (ValueType( *)[2]) mxGetPr(points_out_matlab);

        for(int idmla = 0; idmla < num_points; ++idmla) {
            ml_array_ptr[idmla][0] = poly_out[idmp].outer()[idmla].template get<0>();
            ml_array_ptr[idmla][1] = poly_out[idmp].outer()[idmla].template get<1>();
        }

        mxSetCell(poly_out_matlab, 0, points_out_matlab);

        // export rings
        for(int idrng = 0; idrng < num_interior_rings; ++idrng) {
            num_points = bg::num_points(poly_out[idmp].inners()[idrng]);
            mxArray *points_out_matlab = mxCreateNumericMatrix(2, num_points, id, mxREAL);
            ValueType(*ml_array_ptr)[2]  = (ValueType( *)[2]) mxGetPr(points_out_matlab);

            for(int idmla = 0; idmla < num_points; ++idmla) {
                ml_array_ptr[idmla][0] = poly_out[idmp].inners()[idrng][idmla].template get<0>();
                ml_array_ptr[idmla][1] = poly_out[idmp].inners()[idrng][idmla].template get<1>();
            }

            mxSetCell(poly_out_matlab, idrng + 1, points_out_matlab);
        }

        mxSetCell(mpoly_out_matlab , idmp, poly_out_matlab);
    }

    return mpoly_out_matlab;
}
#endif

template<typename ValueType>
void correct_multipolygon(typename bpoly_types<ValueType>::multipolygon_type &poly_ref,  bpolyclip_options const &bpo )
{
    if(bpo.spike_diameter > 0) {
        typename bpoly_types<ValueType>::multipolygon_type poly_tmp;
        bg::remove_by_distance_nico<typename bpoly_types<ValueType>::point_type> spike_policy_nico((ValueType)bpo.spike_diameter);
        bg::remove_spikes(poly_ref, poly_tmp, spike_policy_nico);
        poly_ref = poly_tmp;
    }

    typedef typename bpoly_types<ValueType>::multipolygon_type multipolygon_type;
    typedef typename bpoly_types<ValueType>::polygon_type polygon_type;
    typedef typename bpoly_types<ValueType>::point_type point_type;
    bool si = true;

    while(si) {
        std::vector<bg::segment_identifier> merge_info;
        si = bg::detail::overlay::has_self_intersections_nico(poly_ref, &merge_info);

        if (merge_info.size() <= 0 || !si) { break; }

        bg::remove_by_move_inside<point_type> remove_detected_crossing((ValueType)bpo.grid_limit, true);
        typename bpoly_types<ValueType>::polygon_type *poly_merge;

        if (merge_info[0].multi_index == merge_info[1].multi_index) {
            poly_merge = &(poly_ref[merge_info[0].multi_index]);
        } else {
#ifndef NO_MATLAB
            mexErrMsgTxt("different multi index don't know what to do\n");
#endif
        }

        if (merge_info[1].ring_index != merge_info[0].ring_index) {
            multipolygon_type ring_merged, poly_cut;
            //bpoly_int_multipolygon_type ring_merged, poly_cut;
            //typedef bg::ring_type<bpoly_int_polygon_type>::type ring_type;
            //typedef typename bpoly_types<ValueType>::polygon_type polygon_type;
            polygon_type ring1, ring2;

            if (merge_info[0].ring_index > merge_info[1].ring_index)
            { reverse(merge_info.begin(), merge_info.end()); }

            int ring1_idx = merge_info[0].ring_index;
            int ring2_idx = merge_info[1].ring_index;
            bg::interior_return_type<polygon_type>::type inners = bg::interior_rings(*poly_merge);
            bg::convert(inners[ring2_idx], ring2);
            // -1 since one ring was already removed
            inners.erase(inners.begin() + ring2_idx);
            bg::correct(ring2);

            if (ring1_idx > 0 ) {
                bg::convert(inners[ring1_idx], ring1);
                inners.erase(inners.begin() + ring1_idx);
                bg::correct(ring1);
                bg::union_(ring1, ring2, ring_merged);
            } else {
                //bg::assign(ring1, poly_merge->outer());
                bg::assign(ring_merged, ring2);
            }

            //
            //if (ring1_idx > 0 ) {
            bg::difference(poly_ref, ring_merged, poly_cut);
            bg::assign(poly_cut, poly_ref);
            //poly_ref = poly_cut;
            //poly_cut = poly_cut == &poly_tmp1 ? &poly_tmp2 : &poly_tmp1;
            //bg::clear(*poly_cut);
            //}
            //else {
            //    bg::assign(poly_merge->outer(), ring_merged[0]);
            //}
        } else if (merge_info[1].segment_index != merge_info[0].segment_index) {
            multipolygon_type ring_merged;
            //typedef bg::ring_type<bpoly_int_polygon_type>::type ring_type;
            int ring1_idx = merge_info[0].ring_index;
            std::vector<int> seg_idx;
            seg_idx.push_back(merge_info[0].segment_index);
            seg_idx.push_back(merge_info[1].segment_index);
            //
            bg::ring_type<polygon_type>::type *ref_ring;

            if (ring1_idx > 0) {
                bg::interior_return_type<polygon_type>::type inners = bg::interior_rings(*poly_merge);
                ref_ring = &(inners[ring1_idx]);
            } else {
                ref_ring = &(bg::exterior_ring(*poly_merge));
            }

            bg::ring_type<polygon_type>::type tmp_ring;
            typedef bg::model::referring_segment<const point_type>  segment_type;
            bool is_si_ring = true;

            for (int ids = 0; is_si_ring && ids <= 1; ++ ids) {
                int seg_tst = seg_idx[ids];
                int seg_ref = seg_idx[(ids + 1) % 2];

                for (int idp = 0; is_si_ring && idp <= 1; ++ idp) {
                    bg::assign(tmp_ring, *ref_ring);
                    tmp_ring.pop_back();
                    seg_tst = (seg_tst + idp) % tmp_ring.size();
                    tmp_ring.erase(tmp_ring.begin() + seg_tst);
                    bg::correct(tmp_ring);
                    is_si_ring = bg::detail::overlay::has_self_intersections_nico(tmp_ring);

                    if (!is_si_ring) {
                        segment_type seg ((*ref_ring)[seg_ref], (*ref_ring)[seg_ref + 1]);
                        int pref_idx = mod(seg_tst - 1, (int)ref_ring->size() - 1);
                        int next_idx = (seg_tst + 1) % (int)ref_ring->size();
                        remove_detected_crossing(seg, (*ref_ring)[pref_idx], (*ref_ring)[seg_tst], (*ref_ring)[seg_tst + 1]);
                    }
                }
            }
        }
    }// while (si);
}

template<typename ValueType>
void clip_multipolygon(typename bpoly_types<ValueType>::multipolygon_type const &poly_ref , typename bpoly_types<ValueType>::multipolygon_type const &poly_clip, typename bpoly_types<ValueType>::multipolygon_type &poly_cut, bpolyclip_options const &bpo )
{
    switch(bpo.clip_method) {
        case DIFFERENCE: {
            bg::difference(poly_ref, poly_clip, poly_cut);
            break;
        }

        case INTERSECTION: {
            bg::intersection(poly_ref, poly_clip, poly_cut);
            break;
        }

        case XOR: {
            bg::sym_difference(poly_ref, poly_clip, poly_cut);
            break;
        }

        case UNION: {
            bg::union_(poly_ref, poly_clip, poly_cut);
            break;
        }

        default
                : {
#ifndef NO_MATLAB
                mexErrMsgTxt(" no such Type ");
#endif
            }
    }

    if(bpo.correct && bpo.grid_limit > 0) {
        correct_multipolygon<ValueType> (poly_cut, bpo);
    }

    //if(bpo.simplify_epsilon > 0) {
    //    multipolygon_type poly_tmp;
    //    bg::simplify(poly_out, poly_tmp, bpo.spike_diameter);
    //    poly_out = poly_tmp;
    //}
    //if(bpo.grid_limit > 0) {
    //    if(bg::touches(poly_out) || bg::intersects(poly_out)) {
    //        multipolygon_type poly_tmp;
    //        bg::remove_by_move_inside<typename bpoly_types<ValueType>::point_type> touch_policy_nico((ValueType)bpo.grid_limit);
    //        bg::remove_touch(poly_out, poly_tmp, touch_policy_nico);
    //        poly_out = poly_tmp;
    //    }
    //}
    // check for self intersections and correct
}

#ifndef NO_MATLAB
template<typename ValueType>
void clip_matlab_input(const int nlhs,  mxArray *plhs[], const int nrhs, const mxArray *prhs[], bpolyclip_options const &bpo, typename bpoly_types<ValueType>::multipolygon_type &poly_out)
{
    // define geometry types, note: types must be predefined in header!!!
    typedef bg::model::point<ValueType, 2, bg::cs::cartesian> point_type;
    typedef bg::model::polygon<point_type, false, true> polygon_type;
    typedef std::vector<polygon_type> multipolygon_type;
    multipolygon_type poly_ref, poly_clip;
    read_multipolygon<ValueType>(prhs[fn_prhs::REF_POLY], poly_ref, bpo);
    read_multipolygon<ValueType>(prhs[fn_prhs::CLIP_POLY], poly_clip, bpo);

    // test and correct input if wanted
    if(bpo.correct) {
        if(bg::intersects(poly_ref) || bg::intersects(poly_clip)) {
            plhs[0] = mxCreateDoubleScalar(mxGetNaN());
            mexWarnMsgTxt("Output is invalid, since one of the polygons is self-intersecting");
            return;
        }

        if(bg::touches(poly_ref) || bg::touches(poly_clip)) {
            plhs[0] = mxCreateDoubleScalar(mxGetNaN());
            mexWarnMsgTxt("Output is invalid, since one of the polygons is self-touching");
            return;
        }

        bg::correct(poly_ref);
        bg::correct(poly_clip);
    }

    clip_multipolygon<ValueType>(poly_ref, poly_clip, poly_out, bpo);
}


template<typename ValueType>
void clip_matlab_input(const int nlhs,  mxArray *plhs[], const int nrhs, const mxArray *prhs[], bpolyclip_options const &bpo)
{
    typedef typename bpoly_types<ValueType>::multipolygon_type multipolygon_type;
    multipolygon_type poly_out;
    clip_matlab_input<ValueType>( nlhs, plhs, nrhs, prhs, bpo, poly_out);
    // write polygon to output
    mxArray *poly_out_matlab = write_multipolygon<ValueType>(poly_out, bpo.id);
    plhs[0] = poly_out_matlab ;

    if (nlhs > 1) {
        double area = (double)bg::area(poly_out);
        plhs[1] = mxCreateDoubleScalar(area);
    }
}

//=========================Exported=========================//
void bpolyclip(int &nlhs, mxArray *plhs[],
               int &nrhs, const mxArray *prhs[])
{
    // check input size
    if((nrhs < 2) || (nrhs > 6)) {
        output_usage();
        return;
    }

    bpolyclip_options bpo;

    //  check if clip type type was given and assigned
    if(nrhs >= 3) {
        int ct = (int)mxGetScalar(prhs[fn_prhs::METHOD]);

        if((ct >= 0) && (ct < 4))
        { bpo.clip_method = ClipMethods(ct); }
        else
        { mexErrMsgTxt("Cliptype is not in Range [0..3]"); }

        if(nrhs > fn_prhs::CHECK) { bpo.correct = mxGetScalar(prhs[fn_prhs::CHECK]) > 0; }

        if(nrhs > fn_prhs::SPIKE_DIAMETER) { bpo.spike_diameter = mxGetScalar(prhs[fn_prhs::SPIKE_DIAMETER]); }

        if(nrhs > fn_prhs::GRID_LIMIT) { bpo.grid_limit = mxGetScalar(prhs[fn_prhs::GRID_LIMIT]); }
    }

    const mxArray *p_clip = prhs[fn_prhs::CLIP_POLY];
    const mxArray *p_ref = prhs[fn_prhs::REF_POLY];
    //bpo.id = mxUNKNOWN_CLASS;

    // fast lane, check if one of the polygons is empty
    if (mxIsEmpty(p_ref)) {
        if(bpo.clip_method == INTERSECTION || bpo.clip_method == DIFFERENCE) { plhs[fn_prhs::REF_POLY] = mxCreateCellMatrix(1, 1); }
        else { plhs[0] = mxDuplicateArray(p_clip); }

        return;
    } else if (mxIsEmpty(p_clip)) {
        if(bpo.clip_method == INTERSECTION) { plhs[0] = mxCreateCellMatrix(1, 1); }
        else { plhs[0] = mxDuplicateArray(p_ref); }

        return;
    }
    // if polygons are not empty unpack and check type
    else {
        while(mxIsCell(p_ref)) { p_ref = mxGetCell(p_ref, 0); }

        bpo.id = mxGetClassID(p_ref);
    }

    switch(bpo.id) {
        case mxDOUBLE_CLASS: {
            clip_matlab_input< double >(nlhs, plhs, nrhs, prhs, bpo);
        }
        break;

        case mxINT64_CLASS: {
            clip_matlab_input< int_least64_t >(nlhs, plhs, nrhs, prhs, bpo);
        }
        break;

        default
                : {
                err << "Format " << bpo.id << " is not supported";
                mexErrMsgTxt(err.str().c_str());
            }
    }
}
#endif


};
