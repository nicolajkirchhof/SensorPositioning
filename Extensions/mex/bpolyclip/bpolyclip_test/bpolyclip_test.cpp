// bpolyclip_test.cpp : Defines the entry point for the console application.
//


#include "stdafx.h"
#define NO_MATLAB
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


//int mod (int const &a, int const &b)
//{
//    //if(b < 0) //you can check for b == 0 separately and do what you want
//    //  return mod(-a, -b);
//    int ret = a % b;
//
//    if(ret < 0)
//    { ret += b; }
//
//    return ret;
//}

int testing_intersections()
{
    typedef int_least64_t valuetype;
    typedef bpoly_int_point_type point_type;
    ifstream myfile ("allpolygons.wkt");
    ifstream combsfile ("combs.txt");
    list<string> lines;

    if (!myfile.is_open() || !combsfile.is_open()) {
        return -1;
    }

    while ( myfile.good() ) {
        string lne;
        getline (myfile, lne);

        if (!lne.empty()) {
            lines.push_back(lne);
            /*bpoly_int_multipolygon_type ptmp;
            boost::geometry::read_wkt(lne, ptmp);
            polys.push_back(ptmp);*/
        }

        //cout << line << endl;
    }

    list<string> comblines;
    long cnt = 0;

    while (combsfile.good()) {
        string lne;
        getline (combsfile, lne);

        if (!lne.empty()) {
            comblines.push_back(lne);
        }
    }

    myfile.close();
    vector<long> comb1(comblines.size());
    vector<long> comb2(comblines.size());
    std::list<string>::iterator itcomb = comblines.begin();

    for (unsigned idl = 0; idl < comblines.size(); ++idl) {
        long c1, c2;
        sscanf_s(itcomb->c_str(), "%d %d", &c1, &c2);
        comb1[idl] = c1;
        comb2[idl] = c2;
    }

    vector<bpoly_int_multipolygon_type> polys(lines.size());
    std::list<string>::iterator it = lines.begin();

    for (unsigned idl = 0; idl < lines.size(); ++idl) {
        bpoly_int_multipolygon_type ply;
        boost::geometry::read_wkt(*it, ply);
        polys[idl] = ply;
        ++it;
    }

    //bpoly_int_polygon_type ptmp;
    //boost::geometry::read_wkt(lines.front(), ptmp);
    //bg::convert(ptmp, first_poly);
    bpolyclip::bpolyclip_options bpo;
    //bpo.clip_method = bpolyclip::INTERSECTION;
    bpo.clip_method = bpolyclip::DIFFERENCE;
    bpo.correct = true;
    bpo.grid_limit = 1;
    bpo.spike_diameter = 0;

    for (long idp = 0; idp < comb1.size(); ++idp) {
        bpoly_int_multipolygon_type out;
        bpolyclip::clip_multipolygon<int_least64_t>(polys[comb1[idp]], polys[comb2[idp]], out, bpo);

        if (idp % 1000 == 0) { std::cout << idp << std::endl; }
    }

    //    std::cout << bg::wkt(out);
    return 0;
}

int _tmain(int argc, _TCHAR *argv[])
{
    return testing_intersections();
    //typedef int_least64_t ValueType;
    //typedef bpoly_int_point_type point_type;
    //list<string> lines;
    //list<string> histlines;
    //bpoly_int_multipolygon_type first_poly;
    //int start_at_line = 1;
    //ifstream myfile ("polygons.wkt");
    //if (myfile.is_open()) {
    //    while ( myfile.good() ) {
    //        string lne;
    //        getline (myfile, lne);
    //        if (!lne.empty())
    //        { lines.push_back(lne); }
    //        //cout << line << endl;
    //    }
    //    myfile.close();
    //    bpoly_int_polygon_type ptmp;
    //    boost::geometry::read_wkt(lines.front(), ptmp);
    //    bg::convert(ptmp, first_poly);
    //}
    //ifstream histfile_in ("polygons_mergehist.wkt");
    //if (histfile_in.is_open()) {
    //    while ( histfile_in.good() ) {
    //        string lne;
    //        getline(histfile_in, lne);
    //        if (!lne.empty())
    //        { histlines.push_back(lne); }
    //        //cout << line << endl;
    //    }
    //    if (histlines.size() > 0) {
    //        histfile_in.close();
    //        start_at_line = histlines.size() / 2;
    //        histlines.pop_back();
    //        bg::clear(first_poly);
    //        boost::geometry::read_wkt(histlines.back(), first_poly);
    //        list<string>::iterator iterase;
    //        iterase = lines.begin();
    //        advance(iterase, start_at_line - 1);
    //        lines.erase(lines.begin(), iterase);
    //    }
    //}
    ////// Calculate the intersects of a cartesian polygon
    ////typedef boost::geometry::model::d2::point_xy<double> point_type;
    ////boost::geometry::model::linestring<P> line1, line2;
    //vector<bpoly_int_multipolygon_type> polyList(lines.size());
    ////BOOST_FOREACH(string & line, lines) {
    //std::list<string>::iterator it = lines.begin();
    //++it;
    //for (unsigned idl = 1; idl < lines.size(); ++idl) {
    //    bpoly_int_polygon_type poly;
    //    boost::geometry::read_wkt(*it++, poly);
    //    //polyList[idl] = poly;
    //    bg::convert(poly, polyList[idl]);
    //    //polyList.push_back(poly);
    //}
    //bpolyclip::bpolyclip_options bpo;
    //bpo.clip_method = bpolyclip::UNION;
    //bpo.correct = true;
    //bpo.grid_limit = 1;
    //bpo.spike_diameter = 10;
    //size_t num_polys = polyList.size();
    //bpoly_int_multipolygon_type poly_tmp1, poly_tmp2;
    //poly_tmp1 = first_poly;
    //bpoly_int_multipolygon_type *poly_cut = &poly_tmp2;
    //bpoly_int_multipolygon_type *poly_ref = &poly_tmp1;
    //bpoly_int_multipolygon_type *poly_clip;
    //bool si = false;
    //ofstream histfile_out;
    //histfile_out.open ("polygons_mergehist.wkt", ios::app);
    //for (size_t idp = 1; idp < num_polys; ++idp) {
    //    // get next poly of joblist, beware of matlab indexing!!!
    //    //poly_clip =
    //    //bpolyclip::clip_multipolygon<ValueType>(*poly_ref, *poly_clip, *poly_cut, cm);
    //    poly_clip = &polyList[idp];
    //    bpolyclip::clip_multipolygon<int_least64_t>(*poly_clip, *poly_ref, *poly_cut, bpo);
    //    //bg::union_(*poly_clip, *poly_ref, *poly_cut);
    //    histfile_out << bg::wkt(*poly_ref) << endl;
    //    histfile_out << bg::wkt(*poly_clip) << endl;
    //    histfile_out.flush();
    //    poly_ref = poly_cut;
    //    poly_cut = poly_cut == &poly_tmp1 ? &poly_tmp2 : &poly_tmp1;
    //    bg::clear(*poly_cut);
    //}
    //histfile_out.close();
    return 0;
}