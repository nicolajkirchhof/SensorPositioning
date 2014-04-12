/**************************************************************************************
 * MATLAB MEX LIBRARY polypartition.mexw64
 *
 * EXPORTS:
 *  void mexFunction(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
 *   whereas prhs = (poly, method)
 *
 * PURPOSE: computes a polygon partitioning
 *
 *  INPUTS:
 *  poly = [DOUBLE values]
 *          ring [2 n],
 *          polygon {[2 n], [...]}
 *          multi_polygon {{[2 n], [...]}{...}}
 *
 *  method  = [int]
 *          0 - Triangulation by ear clipping
 *          1 - Optimal triangulation in terms of edge length using dynamic programming algorithm
 *          2 - Triangulation by partition into monotone polygons
 *          3 - Convex partition using Hertel-Mehlhorn algorithm
 *          4 - Optimal convex partition using dynamic programming algorithm by Keil and Snoeyink
 *
 *  OUTPUTS: list of convex polygons
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

#include "polypartition.h"
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
        "/**************************************************************************************		  \n"
        " * MATLAB MEX LIBRARY polypartition.mexw64														  \n"
        " *																								  \n"
        " * EXPORTS:																					  \n"
        " *  void mexFunction(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])			  \n"
        " *   whereas prhs = (poly, method)																  \n"
        " *																								  \n"
        " * PURPOSE: computes a polygon partitioning													  \n"
        " *																								  \n"
        " *  INPUTS:																					  \n"
        " *  poly = [DOUBLE or INT64 values] CLOSED!!!													  \n"
        " *          ring [2 n],																		  \n"
        " *          polygon {[2 n], [...]}																  \n"
        " *          multi_polygon {{[2 n], [...]}{...}}												  \n"
        " *																								  \n"
        " *  method  = [int]																			  \n"
        " *          0 - Triangulation by ear clipping													  \n"
        " *          1 - Optimal triangulation in terms of edge length using dynamic programming algorithm\n"
        " *          2 - Triangulation by partition into monotone polygons								  \n"
        " *          3 - Convex partition using Hertel-Mehlhorn algorithm								  \n"
        " *			 4 - Optimal convex partition using dynamic programming algorithm by Keil and Snoeyink\n"
        " *																								  \n"
        " *  OUTPUTS: list of convex polygons															  \n"
        " *  prhs {[2 n], [...]}																		  \n"
        " *																								  \n"
        " * Compilation:																				  \n"
        " *  TO BE DONE																					  \n"
        " *  >> mex -O -v polypartion_matlab.cpp														  \n"
        " *  (add -largeArrayDims mex option on 64-bit computer)										  \n"
        " * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>										  \n"
        " * History																						  \n"
        " *  Original: 19-Dec-2012																		  \n"
        " **************************************************************************************/		  \n"
    );
}

namespace fn_prhs {
enum names {
    POLY        = 0,
    METHOD      = 1
};
}

namespace PartitionMethods {
enum PartitionMethods {
    UNKNOWN_METHOD = -1,
    TRIANGULATE_EC = 0,
    TRIANGULATE_OPT = 1,
    TRIANGULATE_MONO = 2,
    CONVEXPARTITION_HM = 3,
    CONVEXPARTITION_OPT = 4
};
}

typedef std::list<TPPLPoly> polygon_type;
typedef TPPLPoly ring_type;

ring_type read_ring(mxArray const *mx_array, bool hole)
{
    TPPLPoly tp;
    // ring assumed to be closed
    size_t num_points = mxGetN(mx_array) - 1;
    size_t point_sz = mxGetM(mx_array);

    // check size
    if(point_sz != 2) {
        mexErrMsgTxt("Point size is not [2 n] for ");
    };

    tp.Init(num_points);

    tp.SetHole(hole);

    mxClassID id = mxGetClassID(mx_array);

    switch (id) {
        case mxINT64_CLASS: {
            int64_T *pts = (int64_T *) mxGetPr(mx_array);

            // ring assumed to be closed
            for (int idp = 0; idp < num_points; ++idp) {
                tp[idp].x = (double)pts[idp << 1];
                tp[idp].y = (double)pts[(idp << 1) + 1];
            }
        }
        break;

        case mxDOUBLE_CLASS: {
            double *pts = mxGetPr(mx_array);

            // ring assumed to be closed
            for (int idp = 0; idp < num_points; idp += 2) {
                tp[idp].x = pts[idp << 1];
                tp[idp].y = pts[(idp << 1) + 1];
            }
        }
        break;

        default:
            err << "Type " << id << " not supported" ;
            mexErrMsgTxt(err.str().c_str());
            break;
    }

    return tp;
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

mxArray *write_polygons(polygon_type partition)
{
    // write polygon to output
    mxArray *mpoly_out_matlab = mxCreateCellMatrix(1, partition.size());
    size_t mpoly_idx = 0;

    for(polygon_type::iterator it = partition.begin(); it != partition.end(); ++it) {
        size_t num_points = (*it).GetNumPoints();
        // assign poly
        mxArray *ring_out_matlab = mxCreateDoubleMatrix(2, num_points + 1, mxREAL);
        double *ml_array_ptr = mxGetPr(ring_out_matlab);

        for(int idmla = 0; idmla < num_points; ++idmla) {
            ml_array_ptr[idmla << 1]   = (*it)[idmla].x;
            ml_array_ptr[(idmla << 1) + 1] = (*it)[idmla].y;
        }

        // close polygon
        ml_array_ptr[num_points << 1]   = (*it)[0].x;
        ml_array_ptr[(num_points << 1) + 1] = (*it)[0].y;
        mxSetCell(mpoly_out_matlab, mpoly_idx, ring_out_matlab);
        mpoly_idx++;
    }

    return mpoly_out_matlab;
}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    // check input size
    if(nrhs != 2) {
        output_usage();
        return;
    }

    //  check if clip type type was given and assigned
    int pm_idx = (int)mxGetScalar(prhs[fn_prhs::METHOD]);
    PartitionMethods::PartitionMethods part_method = PartitionMethods::UNKNOWN_METHOD;

    if((pm_idx >= 0) && (pm_idx <= 4))
    { part_method = PartitionMethods::PartitionMethods(pm_idx); }
    else
    { mexErrMsgTxt("Cliptype is not in Range [0..3]"); }

    // fast lane, check if the polygons is empty
    if (mxIsEmpty(prhs[fn_prhs::POLY])) {
        plhs[0] = mxCreateCellMatrix(1, 1);
        return;
    }

    TPPLPartition pp;
    polygon_type input_polygon, polygon_partition, temp_polygon;
    input_polygon = read_polygon(prhs[fn_prhs::POLY]);

    switch(pm_idx) {
        case PartitionMethods::CONVEXPARTITION_HM: {
            //if (input_polygon.size() > 1) {
            //    pp.RemoveHoles(&input_polygon, &temp_polygon);
            //    input_polygon = temp_polygon;
            //}

            pp.ConvexPartition_HM(&input_polygon, &polygon_partition);
            break;
        }

        case PartitionMethods::CONVEXPARTITION_OPT: {
            if (input_polygon.size() > 1) {
                pp.RemoveHoles(&input_polygon, &temp_polygon);
                input_polygon = temp_polygon;
            }

            pp.ConvexPartition_OPT(&input_polygon.front(), &polygon_partition);
            break;
        }

        case PartitionMethods::TRIANGULATE_EC: {
            pp.Triangulate_EC(&input_polygon, &polygon_partition);
            break;
        }

        case PartitionMethods::TRIANGULATE_MONO: {
            pp.Triangulate_MONO(&input_polygon, &polygon_partition);
            break;
        }

        case PartitionMethods::TRIANGULATE_OPT: {
            pp.Triangulate_OPT(&input_polygon.front(), &polygon_partition);
            break;
        }

        default
                : {
                mexErrMsgTxt(" no such Type ");
            }
    }

    plhs[0] = write_polygons(polygon_partition);
}

