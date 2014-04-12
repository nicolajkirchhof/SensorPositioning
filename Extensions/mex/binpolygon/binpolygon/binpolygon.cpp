/**************************************************************************************
 * MATLAB MEX LIBRARY bpolyclip_batch.dll
 *
 * EXPORTS:
 *  [in on] mexFunction(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
 *   whereas prhs = (points, poly, tol, hulltest)
 *
 * PURPOSE: engine to compute if point(s) are located within a polygon (with holes)
 *
 *  INPUTS:
 *  point(s) = [2 n] [chooseable, INT64 or DOUBLE supported]
 *  poly     = [chooseable, INT64 or DOUBLE supported, must be same type as Points]
 *              ring [2 n],
 *              polygon {[2 n], ...}
 *              multi_polygon {{[2 n], ... }, ...}
 *
 *  tol  = [double] single value that states the tol to which point is considered to be on a line
 *  hulltest = [bool] states if a test against the octal polygon hull should be performed
 *
 *  OUTPUTS:
 *  in = logical[1 n] points in or on polygon
 *  optional:
 *  on = logical[1 n] points on polygon
 *
 * Compilation:
 *  >> matlab_install.m
 * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
 * History
 *  Original: 19-Dec-2012
 **************************************************************************************/

#include <map>
#include <list>
#include <string>
#include <sstream>
#include <set>
#include <boost/cstdint.hpp>

#include <mex.h>
#include <matrix.h>
#include <math.h>

// returns usage in case of wrong inputs
void output_usage()
{
    mexPrintf (
        "/************************************************************************************** \n"
        " * MATLAB MEX LIBRARY bpolyclip_batch.dll												 \n"
        " *																						 \n"
        " * EXPORTS:																			 \n"
        " *  [in on] mexFunction(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[]) \n"
        " *   whereas prhs = (points, poly, tol, hulltest)										 \n"
        " *																						 \n"
        " * PURPOSE: engine to compute if point(s) are located within a polygon (with holes)	 \n"
        " *																						 \n"
        " *  INPUTS:																			 \n"
        " *  point(s) = [2 n] [chooseable, INT64 or DOUBLE supported]							 \n"
        " *  poly     = [chooseable, INT64 or DOUBLE supported, must be same type as Points]	 \n"
        " *              ring [2 n],															 \n"
        " *              polygon {[2 n], ...}													 \n"
        " *              multi_polygon {{[2 n], ... }, ...}										 \n"
        " *																						 \n"
        " *  tol  = [double] single value that states the tol to which point is considered 		 \n"
        " *		to be on a line																	 \n"
        " *																						 \n"
        " *  OUTPUTS:																			 \n"
        " *  in = logical[1 n] points in or on polygon											 \n"
        " *  optional:																			 \n"
        " *  on = logical[1 n] points on polygon												 \n"
        " *																						 \n"
        " * Compilation:																		 \n"
        " *  >> matlab_install.m																 \n"
        " * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>								 \n"
        " * History																				 \n"
        " *  Original: 19-Dec-2012																 \n"
        " **************************************************************************************/\n"
    );
}

enum input_format {
    MULTIPOLY,
    POLY,
    RING,
    UNKNOWN
};

struct binpolygon_options {
    binpolygon_options() : tol ( 0 ), input_type ( mxUNKNOWN_CLASS ), npoints ( 0 ), npolygons ( 1 ), format ( UNKNOWN ), is_octhull ( true )
    {};
    size_t npoints;
    size_t npolygons;
    input_format format;
    bool is_octhull;
    double tol;

    // check for given format
    mxClassID input_type;
};

template <typename Type>
struct octal_hull {
    Type xmin;
    Type xmax;
    Type ymin;
    Type ymax;
    Type pmin;
    Type pmax;
    Type qmin;
    Type qmax;
};

template <typename Type>
struct sorted_idx {
    Type xval;
    unsigned idx;

    inline sorted_idx ( Type _xval = 0, unsigned _id = 0 ) : xval ( _xval ), idx ( _id ) {}

    inline bool operator< ( const sorted_idx<Type> &comp ) const {
        return xval < comp.xval;
    }

    inline bool operator< ( const Type &comp ) const {
        return xval < comp;
    }
};

template< typename Type>
struct polygon_ring {
    Type const ( *vertices ) [2];
    size_t num_vertices;

};

namespace fn_prhs {
enum names {
    POINTS   = 0,
    POLYGONS = 1,
    TOL      = 2,
	HULLTEST = 3
};
}

namespace fn_plhs {
enum names {
    IN       = 0,
    ON       = 1
};
}

// Define Assignment
#define X 0
#define Y 1


template< typename Type>
void check_intersection (Type const &px, Type const &py, polygon_ring<Type> const &ring, unsigned &idx_v, double const &eps, mxLogical &in, mxLogical &on )
{
    Type const &lx0 = ring.vertices[idx_v - 1][X];
    Type const &ly0 = ring.vertices[idx_v - 1][Y];
    Type const &lx1 = ring.vertices[idx_v][X];
    Type const &ly1 = ring.vertices[idx_v][Y];

    // edge is below, neglect
    if ((ly0 < ly1 && ly1 < py) || (ly1 < ly0 && ly0 < py))
    { return; }

    // special case, point has same x coordinate as verticy;
    if( (px == lx0) || (px == lx1) ) {
        // point on verticy
        if ((px == lx0 && py == ly0) || (px == lx1 && py == ly1)) {
            on = true;
            in = true;
        }
        // check if crossing, only once when px == lx0
        else if (px == lx0) {
            if (!is_crossing(px, ring, idx_v))
            { return; }
        } else
        { return; }
    }


    // try to get out in +y direction
    // edge is above point
    if ( ly0 > py && ly1 > py ) {
        // both edge points are above tst point there must be an intersection
        if ( !on ) {
            in = !in;
        }
    } else if ( ( ly1 <= py && ly0 >= py ) || ( ly0 <= py && ly1 >= py ) ) {
        // one edge point is above the testpoint therefore exact test must be performed
        // s = ly0 - y + ldy*(x-lx0)/ldx
        // calculation is done in double to get an accurate result
        double s = ( ly0 - py ) +  ( ly1 - ly0 ) * ( px - lx0 ) / ( ( double ) ( lx1 - lx0 ) );

        if ( s == 0 ||
                ( eps > 0 && ( ( s > 0 && s <= eps ) || ( s < 0 && s >= -eps ) ) ) ) {
            on = true;
            in = true;
        } else if ( s > 0 && !on )
        { in = !in; }
    }
}

template< typename Type >
bool is_crossing ( Type const &px, polygon_ring<Type> const &ring, unsigned const &idx_v )
{
    unsigned idprevious = idx_v - 1;

    if (px == ring.vertices[idprevious][X]) {
        idprevious = idx_v - 1 < 0 ? ring.num_vertices : idx_v - 1;

        // find verticy before the spike/crossing
        for ( unsigned loop = 0; loop <= 1 && px == ring.vertices[idprevious][X]; --idprevious) {
            // cycle ring
            if ( idprevious == 0 ) {
                idprevious = ring.num_vertices - 1;
                ++loop;
            }
        }
    }

    // test which is the next verticie that defines if we have a spike or crossing
    unsigned idnext = idx_v;

    for ( unsigned loop = 0; loop <= 1 && px == ring.vertices[idnext][X]; ++idnext ) {
        // cycle ring
        if ( idnext >= ring.num_vertices - 1 ) {
            idnext = 0;
            ++loop;
        }
    }

    if ( ( ring.vertices[idprevious][X] < px && ring.vertices[idnext][X] > px ) ||
            ( ring.vertices[idprevious][X] > px && ring.vertices[idnext][X] < px ) )
    { return true; }

    return false;
}

template< typename Type >
void binpolygon_ring ( Type const ( *points ) [2], mxArray const *ml_ring, binpolygon_options const &bio, mxLogical *in, mxLogical *on )
{
    polygon_ring<Type> ring;
    ring.vertices = ( Type ( * ) [2] ) mxGetPr ( ml_ring );
    ring.num_vertices = mxGetN ( ml_ring );
    double const &nvertices = ring.num_vertices;

    //size_t nvertices = mxGetN ( ring );
    // check if points are in octal hull

    // min verticies is 3 but ring must be closed
    if ( nvertices < 4 ) {
        std::ostringstream err;
        err << "Ring [" ;

        for ( unsigned i = 0; i < nvertices; i++ )
        { err << "[" << ring.vertices[i][X] << ";" << ring.vertices[i][Y] << "] "; }

        err << "]";
        mexErrMsgTxt ( err.str().c_str() );
    }

    if ( bio.is_octhull ) {
        std::multiset<sorted_idx<Type> > pts_inhull;
        octal_hull<Type> hull;
        // Calculate the octal hull
        // calculate bounding octagon
        hull.xmin = ring.vertices[0][X];
        hull.xmax = hull.xmin;
        hull.ymin = ring.vertices[0][Y];
        hull.ymax = hull.ymin;
        hull.pmax = ring.vertices[0][X] + ring.vertices[0][Y];
        hull.pmin = hull.pmax;
        hull.qmax = ring.vertices[0][X] - ring.vertices[0][Y];
        hull.qmin = hull.qmax;

        for ( unsigned idx_v = 1; idx_v < nvertices; ++idx_v ) {
            if ( ring.vertices[idx_v][X] < hull.xmin )
            { hull.xmin = ring.vertices[idx_v][X]; }

            if ( ring.vertices[idx_v][X] > hull.xmax )
            { hull.xmax = ring.vertices[idx_v][X]; }

            if ( ring.vertices[idx_v][Y] < hull.ymin )
            { hull.ymin = ring.vertices[idx_v][Y]; }

            if ( ring.vertices[idx_v][Y] > hull.ymax )
            { hull.ymax = ring.vertices[idx_v][Y]; }

            if ( ring.vertices[idx_v][X] + ring.vertices[idx_v][Y] < hull.pmin )
            { hull.pmin = ring.vertices[idx_v][X] + ring.vertices[idx_v][Y]; }

            if ( ring.vertices[idx_v][X] + ring.vertices[idx_v][Y] > hull.pmax )
            { hull.pmax = ring.vertices[idx_v][X] + ring.vertices[idx_v][Y]; }

            if ( ring.vertices[idx_v][X] - ring.vertices[idx_v][Y] < hull.qmin )
            { hull.qmin = ring.vertices[idx_v][X] - ring.vertices[idx_v][Y]; }

            if ( ring.vertices[idx_v][X] - ring.vertices[idx_v][Y] > hull.qmax )
            { hull.qmax = ring.vertices[idx_v][X] - ring.vertices[idx_v][Y]; }
        }

        // only consider points in hull
        for ( unsigned idpt = 0; idpt < bio.npoints; ++idpt ) {
            if ( points[idpt][X] >= hull.xmin && points[idpt][X] <= hull.xmax
                    && points[idpt][Y] >= hull.ymin && points[idpt][Y] <= hull.ymax
                    && points[idpt][X] + points[idpt][Y] >= hull.pmin && points[idpt][X] + points[idpt][Y] <= hull.pmax
                    && points[idpt][X] - points[idpt][Y] >= hull.qmin && points[idpt][X] - points[idpt][Y] <= hull.qmax ) {
                sorted_idx<Type> idx ( points[idpt][X], idpt );
                pts_inhull.insert ( idx );
            }
        }

        // check every vertex
        if ( pts_inhull.size() > 0 ) {
            for ( unsigned idx_v = 1; idx_v < nvertices; ++idx_v ) {
                typename std::multiset<sorted_idx<Type> >::iterator it, itlow, itup;

                // get relevant points thease are only the points where the x coordinate changes in order to prohibit
                // multiple crossings
                if ( ring.vertices[idx_v - 1][X] < ring.vertices[idx_v][X] ) {
                    itlow = pts_inhull.lower_bound ( ring.vertices[idx_v - 1][X] );
                    itup = pts_inhull.upper_bound ( ring.vertices[idx_v][X] );
                } else if ( ring.vertices[idx_v - 1][X] > ring.vertices[idx_v][X] ) {
                    itlow = pts_inhull.lower_bound ( ring.vertices[idx_v][X] );
                    itup = pts_inhull.upper_bound ( ring.vertices[idx_v - 1][X] );
                } else {
                    // points are
                    itlow = pts_inhull.lower_bound ( ring.vertices[idx_v - 1][X] );
                    itup = pts_inhull.upper_bound ( ring.vertices[idx_v][X] );

                    for ( it = itlow; it != itup; ++it ) {
                        if(( ring.vertices[idx_v - 1][Y] > points[it->idx][Y] && ring.vertices[idx_v][Y] < points[it->idx][Y])
                                || ( ring.vertices[idx_v - 1][Y] < points[it->idx][Y] && ring.vertices[idx_v][Y] > points[it->idx][Y])) {
                            on[it->idx] = true;
                            in[it->idx] = true;
                        }
                    }

                    continue;
                }

                // check points in convex hull
                for ( it = itlow; it != itup; ++it ) {
                    if ( on[it->idx] )
                    { continue; }

                    check_intersection<Type> ( points[it->idx][X], points[it->idx][Y], ring, idx_v,  bio.tol,  in[it->idx], on[it->idx] );
                }
            }
        }
    } else { // no octhull just test every point against every vertex
        for ( unsigned idx_v = 1; idx_v < nvertices; ++idx_v ) {
            for ( unsigned idpt = 0; idpt < bio.npoints; ++idpt ) {
                // actually tol has to be applied to the left and right side of edge  x->|..........|<-x but is neglected since I do not care for this special case
                if ( on[idpt] )
                { continue; }

                if //check if point can cross edge
                ((points[idpt][X] >= ring.vertices[idx_v - 1][X] && points[idpt][X] <= ring.vertices[idx_v][X] )
                        || (points[idpt][X] <= ring.vertices[idx_v - 1][X] && points[idpt][X] >= ring.vertices[idx_v][X] ) ) {
                    // check for vertical edge
                    if ( ring.vertices[idx_v - 1][X] != ring.vertices[idx_v][X] ) {

                        check_intersection<Type> ( points[idpt][X], points[idpt][Y], ring, idx_v, bio.tol, in[idpt], on[idpt] );
                    }
                    // check if point is on vertical edge
                    else if ((points[idpt][Y] <= ring.vertices[idx_v - 1][Y] && points[idpt][Y] >= ring.vertices[idx_v][Y] ) ||
                             (points[idpt][Y] >= ring.vertices[idx_v - 1][Y] && points[idpt][Y] <= ring.vertices[idx_v][Y])) {
                        in[idpt] = true;
                        on[idpt] = true;
                    }

                }
            }
        }
    }
}

template< typename Type >
void binpolygon_poly ( Type const ( *points ) [2], mxArray const *poly, binpolygon_options const &bio, mxLogical *in, mxLogical *on )
{
    // get number of rings
    size_t nrings = mxGetN ( poly ) > mxGetM ( poly ) ? mxGetN ( poly ) : mxGetM ( poly );

    for ( unsigned idr = 0; idr < nrings; ++idr ) {
        binpolygon_ring<Type> ( points, mxGetCell ( poly, idr ), bio, in, on );
    }
}

template < typename Type >
//void binpolygon(int nlhs, mxArray *plhs[], int nrhs, mxArray const *prhs[], binpolygon_options &bio)
void binpolygon ( const mxArray *points, const mxArray *polygon, binpolygon_options const &bio, mxLogical *in, mxLogical *on )
{
    //// used types
    Type ( *points_array ) [2] = ( Type ( * ) [2] ) mxGetPr ( points );

    switch ( bio.format ) {
        case MULTIPOLY :
            for ( unsigned idp = 0; idp < bio.npolygons; ++idp ) {
                binpolygon_poly ( points_array, mxGetCell ( polygon, idp ), bio, in, on );
            }

            break;

        case POLY :
            binpolygon_poly<Type> ( points_array, polygon, bio, in, on );
            break;

        case RING :
            binpolygon_ring<Type> ( points_array, polygon, bio, in, on );
            break;

        case UNKNOWN:
            mexErrMsgTxt ( "unnown input type" );
    }
}

void mexFunction ( int nlhs, mxArray *plhs[],
                   int nrhs, const mxArray *prhs[] )
{
    // check input
    if ( nrhs < 2 || nrhs > 4 || mxGetM ( prhs[fn_prhs::POINTS] ) != 2 || mxGetN ( prhs[fn_prhs::POINTS] ) < 1 || mxIsEmpty ( prhs[fn_prhs::POLYGONS] ) ) {
        output_usage();
        return;
    }

    binpolygon_options bio;
    // input ok get num of points
    bio.npoints = mxGetN ( prhs[fn_prhs::POINTS] );

    // check if polygons are not empty and which Type, size they have
    if ( mxIsCell ( prhs[fn_prhs::POLYGONS] ) ) {
        mxArray *multi_poly = mxGetCell ( prhs[fn_prhs::POLYGONS], 0 );

        if ( mxIsCell ( multi_poly ) ) {
            bio.format = MULTIPOLY;
            bio.npolygons = mxGetM (  prhs[fn_prhs::POLYGONS] ) > mxGetN (  prhs[fn_prhs::POLYGONS] ) ? mxGetM (  prhs[fn_prhs::POLYGONS] ) : mxGetN (  prhs[fn_prhs::POLYGONS] );
            bio.input_type = mxGetClassID ( mxGetCell ( mxGetCell ( prhs[fn_prhs::POLYGONS], 0 ), 0 ) );
        } else {
            bio.format = POLY;
            bio.input_type = mxGetClassID ( mxGetCell ( prhs[fn_prhs::POLYGONS], 0 ) );
        }
    } else if ( mxGetM ( prhs[fn_prhs::POLYGONS] ) == 2 ) { // is polygon just 2xn array?
        bio.input_type = mxGetClassID ( prhs[fn_prhs::POLYGONS] );
        bio.format = RING;
    } else {
        output_usage();
        return;
    }

    if ( nrhs > 2 ) {
        bio.tol = mxGetScalar ( prhs[fn_prhs::TOL] );

        if ( nrhs > 3 )
		{ bio.is_octhull = mxGetScalar ( prhs[fn_prhs::HULLTEST] ) != 0; }
    }

    // check if points, polygons and possibly tolerance all have the same type
    if ( mxGetClassID ( prhs[fn_prhs::POINTS] ) != bio.input_type ) {
        std::ostringstream err;
        err << "Polygon type " << bio.input_type << " does not match point type " << mxGetClassID ( prhs[fn_prhs::TOL] ) << "! \n";
        mexErrMsgTxt ( err.str().c_str() );
    }

    // create return vectors
    plhs[fn_plhs::IN] = mxCreateLogicalMatrix ( 1, bio.npoints );
    plhs[fn_plhs::ON] = mxCreateLogicalMatrix ( 1, bio.npoints );
    mxLogical *in = ( mxLogical * ) mxGetPr ( plhs[fn_plhs::IN] );
    mxLogical *on = ( mxLogical * ) mxGetPr ( plhs[fn_plhs::ON] );

    switch ( bio.input_type ) {
        case mxDOUBLE_CLASS: {
            //double tol = (nrhs>2)?mxGetScalar(TOL):0.0;
            binpolygon< double > ( prhs[fn_prhs::POINTS], prhs[fn_prhs::POLYGONS], bio, in, on );
        }
        break;

        case mxINT64_CLASS: {
            //int_least64_t tol = (nrhs>2)?*((int_least64_t*)mxGetData(TOL)):0;
            binpolygon<int_least64_t> ( prhs[fn_prhs::POINTS], prhs[fn_prhs::POLYGONS], bio, in, on );
        }
        break;

        default
                : {
                std::ostringstream err;
                err << "Format " << bio.input_type << " is not supported";
                mexErrMsgTxt ( err.str().c_str() );
            }
    }

	if ( nlhs < 2 ) { mxDestroyArray ( plhs[fn_plhs::ON] ); }

    return;
};
