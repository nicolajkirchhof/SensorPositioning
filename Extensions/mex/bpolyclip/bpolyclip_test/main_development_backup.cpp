// bpolyclip_test.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "..\bpolyclip\bpolyclip.hpp"

using namespace std;
namespace bg = boost::geometry;
//
//BOOST_GEOMETRY_REGISTER_C_ARRAY_CS(cs::cartesian)
//
//typedef bg::model::point<int_least64_t, 2, bg::cs::cartesian> bpoly_int_point_type;
//typedef bg::model::polygon<bpoly_int_point_type, false, true> bpoly_int_polygon_type;
//typedef std::vector<bpoly_int_polygon_type> bpoly_int_multipolygon_type;
////namespace boost::geometry bg
//
//BOOST_GEOMETRY_REGISTER_RING(std::vector<bpoly_int_point_type>)
//BOOST_GEOMETRY_REGISTER_MULTI_POLYGON(bpoly_int_multipolygon_type)


int mod (int const &a, int const &b)
{
    //if(b < 0) //you can check for b == 0 separately and do what you want
    //  return mod(-a, -b);
    int ret = a % b;

    if(ret < 0)
    { ret += b; }

    return ret;
}



int _tmain(int argc, _TCHAR *argv[])
{
    typedef int_least64_t ValueType;
    typedef bpoly_int_point_type point_type;
    list<string> lines;
    list<string> histlines;

    bpoly_int_multipolygon_type first_poly;
    int start_at_line = 1;

    ifstream myfile ("polygons.wkt");

    if (myfile.is_open()) {
        while ( myfile.good() ) {
            string lne;
            getline (myfile, lne);

            if (!lne.empty())
            { lines.push_back(lne); }

            //cout << line << endl;
        }

        myfile.close();
        bpoly_int_polygon_type ptmp;
        boost::geometry::read_wkt(lines.front(), ptmp);
        bg::convert(ptmp, first_poly);
    }

    ifstream histfile_in ("polygons_mergehist.wkt");

    if (histfile_in.is_open()) {
        while ( histfile_in.good() ) {
            string lne;
            getline(histfile_in, lne);

            if (!lne.empty())
            { histlines.push_back(lne); }

            //cout << line << endl;
        }

        if (histlines.size() > 0) {
            histfile_in.close();
            start_at_line = histlines.size() / 2;
            histlines.pop_back();
            bg::clear(first_poly);
            boost::geometry::read_wkt(histlines.back(), first_poly);

            list<string>::iterator iterase;
            iterase = lines.begin();
            advance(iterase, start_at_line - 1);
            lines.erase(lines.begin(), iterase);
        }
    }

    //// Calculate the intersects of a cartesian polygon
    //typedef boost::geometry::model::d2::point_xy<double> point_type;
    //boost::geometry::model::linestring<P> line1, line2;

    vector<bpoly_int_multipolygon_type> polyList(lines.size());


    //BOOST_FOREACH(string & line, lines) {
    std::list<string>::iterator it = lines.begin();
    ++it;

    for (unsigned idl = 1; idl < lines.size(); ++idl) {
        bpoly_int_polygon_type poly;
        boost::geometry::read_wkt(*it++, poly);
        //polyList[idl] = poly;
        bg::convert(poly, polyList[idl]);
        //polyList.push_back(poly);
    }

    bg::remove_by_distance_nico<point_type> spike_policy_nico(10);

    bg::remove_by_move_inside<point_type> touch_policy_nico(1);


    size_t num_polys = polyList.size();
    bpoly_int_multipolygon_type poly_tmp1, poly_tmp2;
    poly_tmp1 = first_poly;
    //bg::assign(poly_tmp1, polyList[0]);
    //bpoly_int_polygon_type poly_tmp3;
    //bg::assign(poly_tmp3, polyList[0]);
    //poly_tmp1.push_back(poly_tmp3);
    bpoly_int_multipolygon_type *poly_cut = &poly_tmp2;
    bpoly_int_multipolygon_type *poly_ref = &poly_tmp1;
    bpoly_int_multipolygon_type *poly_clip;
    bool si = false;

    ofstream histfile_out;
    histfile_out.open ("polygons_mergehist.wkt", ios::app);
    

    for (size_t idp = 1; idp < num_polys; ++idp) {

        do {
            vector<bg::segment_identifier> merge_info;
            bg::remove_by_move_inside<point_type> remove_detected_crossing(1, true);
            si = bg::detail::overlay::has_self_intersections_nico(*poly_ref, &merge_info);

            if (merge_info.size() <= 0 || !si) { break; }

            bpoly_int_polygon_type *poly_merge;

            if (merge_info[0].multi_index == merge_info[1].multi_index) {
                poly_merge = &((*poly_ref)[merge_info[0].multi_index]);
            } else {
                ofstream matfile;
                matfile.open ("polygons_unhandled.wkt");
                matfile << bg::wkt(*poly_ref) << endl;
                matfile.close();
                cout << "ERROR different multi indexes \n";
                return(-1);
            }

            if (merge_info[1].ring_index != merge_info[0].ring_index) {
                bpoly_int_multipolygon_type ring_merged;
                //typedef bg::ring_type<bpoly_int_polygon_type>::type ring_type;
                bpoly_int_polygon_type ring1, ring2;

                if (merge_info[0].ring_index > merge_info[1].ring_index)
                { reverse(merge_info.begin(), merge_info.end()); }

                int ring1_idx = merge_info[0].ring_index;
                int ring2_idx = merge_info[1].ring_index;

                bg::interior_return_type<bpoly_int_polygon_type>::type inners = bg::interior_rings(*poly_merge);

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
                bg::difference(*poly_ref, ring_merged, *poly_cut);
                poly_ref = poly_cut;
                poly_cut = poly_cut == &poly_tmp1 ? &poly_tmp2 : &poly_tmp1;
                bg::clear(*poly_cut);
                //}

                //else {
                //    bg::assign(poly_merge->outer(), ring_merged[0]);
                //}


            } else if (merge_info[1].segment_index != merge_info[0].segment_index) {

                bpoly_int_multipolygon_type ring_merged;
                //typedef bg::ring_type<bpoly_int_polygon_type>::type ring_type;

                int ring1_idx = merge_info[0].ring_index;
                vector<int> seg_idx;
                seg_idx.push_back(merge_info[0].segment_index);
                seg_idx.push_back(merge_info[1].segment_index);

                //
                if (ring1_idx < 0) {
                    cout << "ERROR exterior ring is selected";
                    return(-1);
                }

                bg::interior_return_type<bpoly_int_polygon_type>::type inners = bg::interior_rings(*poly_merge);
                bg::ring_type<bpoly_int_polygon_type>::type tmp_ring, &ref_ring = inners[ring1_idx];

                typedef bg::model::referring_segment<const bpoly_int_point_type>  segment_type;

                bool is_si_ring = true;

                for (int ids = 0; is_si_ring && ids <= 1; ++ ids) {
                    int seg_tst = seg_idx[ids];
                    int seg_ref = seg_idx[(ids + 1) % 2];

                    for (int idp = 0; is_si_ring && idp <= 1; ++ idp) {

                        bg::assign(tmp_ring, ref_ring);
                        tmp_ring.pop_back();
                        seg_tst = (seg_tst + idp) % tmp_ring.size();
                        tmp_ring.erase(tmp_ring.begin() + seg_tst);
                        bg::correct(tmp_ring);
                        is_si_ring = bg::detail::overlay::has_self_intersections_nico(tmp_ring);

                        if (!is_si_ring) {
                            segment_type seg (ref_ring[seg_ref], ref_ring[seg_ref + 1]);
                            int pref_idx = mod(seg_tst - 1, ref_ring.size() - 1);
                            int next_idx = (seg_tst + 1) % ref_ring.size();
                            remove_detected_crossing(seg, ref_ring[pref_idx], ref_ring[seg_tst], ref_ring[seg_tst + 1]);
                        }
                    }

                }

            }

        } while (si);

        // get next poly of joblist, beware of matlab indexing!!!
        //poly_clip =

        //bpolyclip::clip_multipolygon<ValueType>(*poly_ref, *poly_clip, *poly_cut, cm);
        poly_clip = &polyList[idp];
        si  = bg::detail::overlay::has_self_intersections_nico(*poly_clip);

        bg::union_(*poly_clip, *poly_ref, *poly_cut);

        histfile_out << bg::wkt(*poly_ref) << endl;
        histfile_out << bg::wkt(*poly_clip) << endl;
        histfile_out.flush();


        poly_ref = poly_cut;
        poly_cut = poly_cut == &poly_tmp1 ? &poly_tmp2 : &poly_tmp1;
        bg::clear(*poly_cut);

        //bg::simplify(*poly_ref, *poly_cut, 1);
        //poly_ref = poly_cut;
        //poly_cut = poly_cut == &poly_tmp1 ? &poly_tmp2 : &poly_tmp1;
        //bg::clear(*poly_cut);

        bg::remove_spikes(*poly_ref, *poly_cut, spike_policy_nico);
        poly_ref = poly_cut;
        poly_cut = poly_cut == &poly_tmp1 ? &poly_tmp2 : &poly_tmp1;
        bg::clear(*poly_cut);

        //if(poly_ref->size() > 1) {
        //    std::cout << "investigate" << endl;
        //}

        //si = bg::detail::overlay::has_self_intersections_nico(*poly_ref);

        //if (si) {

        //    bg::remove_touch(*poly_ref, *poly_cut, touch_policy_nico);
        //    poly_ref = poly_cut;
        //    poly_cut = poly_cut == &poly_tmp1 ? &poly_tmp2 : &poly_tmp1;
        //    bg::clear(*poly_cut);


        //}
    }

    histfile_out.close();


    return 0;
}

