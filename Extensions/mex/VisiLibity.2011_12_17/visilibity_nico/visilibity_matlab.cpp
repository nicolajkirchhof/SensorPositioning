/**************************************************************************************
* MATLAB MEX LIBRARY visilibity.mexw64
*
* EXPORTS:
*  void mexFunction(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
*   whereas prhs = (points, poly, epsilon)
*
* PURPOSE: computes a polygon visibility_polygoning
*
*  INPUTS:
*  points = [DOUBLE or INT64 values] will be cast into double values
*          [2 n] Matrix of points
*  poly = [DOUBLE or INT64 values] will be cast into double values
*          ring [2 n],
*          polygon {[2 n], [...]}
*          multi_polygon {{[2 n], [...]}{...}}
* epsilon = [DOUBLE default = 0] double accuracy
* spike_distance = [DOUBLE default = 0] spikes with dist < s_d will be removed
* progress_bar = [BOOL = false] returns progress
*
*  OUTPUTS: list of simple visibility polygons
*  prhs {[2 n], [...]}
*
* Compilation:
*  TO BE DONE
*  >> mex -O -v polypartion_matlab.cpp
*  (add -largeArrayDims mex option on 64-bit computer)
* Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
* History
*  Original: 19-Dec-2012
**************************************************************************************/

#include "visilibity.hpp"
#include <iostream>
#include <list>

#include <string>
#include <sstream>


//Gives Matlab interfacing.  Linkage block specifies linkage
//convention used to link header file; makes the C header suitable for
//C++ use.  "mex.h" also includes "matrix.h" to provide MX functions
//to support Matlab data types, along with the standard header files
//<stdio.h>, <stdlib.h>, and <stddef.h>.
#include <matrix.h>
#include <mat.h>
#include <mex.h>
//#include <engine.h>
#define  BUFSIZE 256

//error stream
std::ostringstream err;

void output_usage()
{
    mexPrintf(
        "/**************************************************************************************  \n"
        " * MATLAB MEX LIBRARY visilibity.mexw64												  \n"
        " *																						  \n"
        " * EXPORTS:																			  \n"
        " *  void mexFunction(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])	  \n"
        " *   whereas prhs = (points, poly, epsilon)											  \n"
        " *																						  \n"
        " * PURPOSE: computes a polygon visibility_polygoning									  \n"
        " *																						  \n"
        " *  INPUTS:																			  \n"
        " *  points = [DOUBLE or INT64 values] will be cast into double values					  \n"
        " *          [2 n] Matrix of points														  \n"
        " *  poly = [DOUBLE or INT64 values] will be cast into double values					  \n"
        " *          ring [2 n],																  \n"
        " *          polygon {[2 n], [...]}														  \n"
        " *          multi_polygon {{[2 n], [...]}{...}}										  \n"
        " * epsilon = double accuracy															  \n"
        " * spike_distance = spikes with dist < s_d will be removed								  \n"
        " * progress_bar = [BOOL = false] returns progress                                        \n"
        " *																						  \n"
        " *  OUTPUTS: list of simple visibility polygons										  \n"
        " *  prhs {[2 n], [...]}																  \n"
        " *																						  \n"
        " * Compilation:																		  \n"
        " *  TO BE DONE																			  \n"
        " *  >> mex -O -v polypartion_matlab.cpp												  \n"
        " *  (add -largeArrayDims mex option on 64-bit computer)								  \n"
        " * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>								  \n"
        " * History																				  \n"
        " *  Original: 19-Dec-2012																  \n"
        "  **************************************************************************************/\n"
    );
}

namespace fn_prhs {
enum names {
    POINTS      = 0,
    POLY        = 1,
    EPSILON      = 2,
    SPIKE_DISTANCE = 3,
    PROGRESS_BAR    = 4,
};
}

typedef std::vector<VisiLibity::Polygon> polygon_type;
typedef VisiLibity::Polygon ring_type;
typedef VisiLibity::Point point_type;
typedef std::vector<point_type> vertices_type;

ring_type read_ring(mxArray const *mx_array, bool hole)
{
    ring_type ring;
    // ring assumed to be closed
    size_t num_points = mxGetN(mx_array) - 1;
    size_t point_sz = mxGetM(mx_array);

    // check size
    if(point_sz != 2) {
        mexErrMsgTxt("Point size is not [2 n] for ");
    };

    vertices_type vertices;

    vertices.resize(num_points);

    mxClassID id = mxGetClassID(mx_array);

    switch (id) {
        case mxINT64_CLASS: {
            int64_T *pts = (int64_T *) mxGetData(mx_array);

            // ring assumed to be closed
            for (int idp = 0; idp < num_points; ++idp) {
                vertices[idp].set_x((double)pts[idp << 1]);
                vertices[idp].set_y((double)pts[(idp << 1) + 1]);
            }
        }
        break;

        case mxDOUBLE_CLASS: {
            double *pts = mxGetPr(mx_array);

            // ring assumed to be closed
            for (int idp = 0; idp < num_points; idp += 2) {
                vertices[idp].set_x(pts[idp << 1]);
                vertices[idp].set_x(pts[(idp << 1) + 1]);
            }
        }
        break;

        default:
            err << "Type " << id << " not supported" ;
            mexErrMsgTxt(err.str().c_str());
            break;
    }

    ring.set_vertices(vertices);
    return ring;
}

polygon_type read_polygon(mxArray const *mx_array, bool hole)
{
    polygon_type poly;

    // check structure
    if ( mxIsCell(mx_array) ) {
        size_t num_elements  = mxGetN(mx_array) > mxGetM(mx_array) ? mxGetN(mx_array) : mxGetM(mx_array);
        polygon_type tmp_poly = read_polygon(mxGetCell(mx_array, 0), false);
        poly.insert(poly.end(), tmp_poly.begin(), tmp_poly.end());

        for (size_t idel = 1; idel < num_elements; ++idel) {
            polygon_type tmp_poly = read_polygon(mxGetCell(mx_array, idel), true);
            poly.insert(poly.end(), tmp_poly.begin(), tmp_poly.end());
        }
    } else {
        poly.push_back(read_ring(mx_array, hole));
    }

    return poly;
}

polygon_type read_polygon(mxArray const *mx_array) {return read_polygon(mx_array, false);}

mxArray *write_polygon(VisiLibity::Visibility_Polygon visibility_polygon)
{
    size_t num_points = visibility_polygon.n();
    // assign poly
    mxArray *poly_out_matlab = mxCreateDoubleMatrix(2, num_points + 1, mxREAL);
    double *ml_array_ptr = mxGetPr(poly_out_matlab);

    for(int idmla = 0; idmla < num_points; ++idmla) {
        ml_array_ptr[idmla << 1]   = visibility_polygon[idmla].x();
        ml_array_ptr[(idmla << 1) + 1] = visibility_polygon[idmla].y();
    }

    // close polygon
    ml_array_ptr[num_points << 1]   = visibility_polygon[0].x();
    ml_array_ptr[(num_points << 1) + 1] = visibility_polygon[0].y();
    return poly_out_matlab;
}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    // check input size
    if(nrhs < 2 || nrhs > 5) {
        output_usage();
        return;
    }

    size_t check_points_2d = mxGetM(prhs[fn_prhs::POINTS]);

    if (check_points_2d != 2) {
        err << "Points first dimension must be 2, not " << check_points_2d;
        mexErrMsgTxt(err.str().c_str());
    }

    size_t num_points = mxGetN(prhs[fn_prhs::POINTS]);

    // fast lane, check if the polygons is empty
    if (mxIsEmpty(prhs[fn_prhs::POLY]) || num_points < 1) {
        plhs[0] = mxCreateCellMatrix(1, num_points);
        return;
    }

    double epsilon = 0;
    double spike_distance = 0;
    bool is_progress_bar;

    switch (nrhs - 1) {
        case fn_prhs::PROGRESS_BAR:
            is_progress_bar = mxGetScalar(prhs[fn_prhs::PROGRESS_BAR]) > 0.0;

        case fn_prhs::SPIKE_DISTANCE:
            spike_distance = mxGetScalar(prhs[fn_prhs::SPIKE_DISTANCE]);

        case fn_prhs::EPSILON:
            epsilon = mxGetScalar(prhs[fn_prhs::EPSILON]);

        default:
            break;
    }

    mxClassID point_class = mxGetClassID(prhs[fn_prhs::POINTS]);
    vertices_type observer_points;
    observer_points.resize(num_points);

    switch (point_class) {
        case mxDOUBLE_CLASS: {
            double *matlab_points = mxGetPr(prhs[fn_prhs::POINTS]);

            for (size_t point_idx = 0; point_idx < num_points; ++point_idx) {
                observer_points[point_idx].set_x(matlab_points[point_idx << 1]);
                observer_points[point_idx].set_y(matlab_points[(point_idx << 1) + 1]);
            }
        }
        break;

        case mxINT64_CLASS: {
            int64_T *matlab_points = (int64_T *) mxGetData(prhs[fn_prhs::POINTS]);

            for (size_t point_idx = 0; point_idx < num_points; ++point_idx) {
                observer_points[point_idx].set_x((double)matlab_points[point_idx << 1]);
                observer_points[point_idx].set_y((double)matlab_points[(point_idx << 1) + 1]);
            }
        } break;

        default:
            break;
    }

    polygon_type environment_polygon = read_polygon(prhs[fn_prhs::POLY]);
    VisiLibity::Environment visilibity_environment(environment_polygon);

    if ( !visilibity_environment.is_valid() ) {
        mexErrMsgTxt("Env not valid");
        return;
    }

    mxArray *matlab_visibility_polygons = mxCreateCellMatrix(1, num_points);
    size_t pct = 0;

    for (size_t point_idx = 0; point_idx < num_points; point_idx++) {
        if (is_progress_bar && (point_idx * 100 / num_points > pct)) {
            pct = point_idx * 100 / num_points;
            mexPrintf(".", pct);
            mexEvalString("drawnow;"); // to dump string.

            if (!(pct % 10)) { mexPrintf("%d", pct / 10); }
        }

        // Ty to adjust observer location according to snap distance
        if(  !observer_points[point_idx].in( visilibity_environment )  ) {
            observer_points[point_idx].snap_to_boundary_of(visilibity_environment , epsilon);
            observer_points[point_idx].snap_to_vertices_of(visilibity_environment , epsilon);

            if (!observer_points[point_idx].in(visilibity_environment, epsilon)) {
                VisiLibity::Point point_temp( observer_points[point_idx].projection_onto_boundary_of(visilibity_environment) );
                mxSetCell(matlab_visibility_polygons, point_idx, mxCreateDoubleMatrix(0, 0, mxREAL));
                err << std::endl << "Point " << observer_points[point_idx].x() << " " << observer_points[point_idx].y() << " at index " << point_idx <<  " with distance " << VisiLibity::distance(observer_points[point_idx], point_temp ) << " is not in polygon or at distance epsilon = " << epsilon << std::endl;
                mexPrintf(err.str().c_str());
                mexEvalString("drawnow;"); // to dump string.
                continue;
            }
        }

        VisiLibity::Visibility_Polygon visibility_polygon = VisiLibity::Visibility_Polygon(observer_points[point_idx], visilibity_environment, epsilon);
        visibility_polygon.eliminate_redundant_vertices(spike_distance);
        mxSetCell(matlab_visibility_polygons, point_idx, write_polygon(visibility_polygon));
    }
    if (is_progress_bar)
        mexPrintf("\n", pct);

    plhs[0] = matlab_visibility_polygons;
}

