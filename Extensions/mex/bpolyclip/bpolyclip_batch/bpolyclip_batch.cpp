/**************************************************************************************
 * MATLAB MEX LIBRARY bpolyclip_batch.dll
 *
 * EXPORTS:
 *  void bpolyclip(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
 *   whereas prhs = (ref_poly, clip_poly, method, correct, pt_merge_dist, spike_diameter)
 *
 * PURPOSE: engine to compute boolean operations on list of polygons per default
 *  the given method is applied to all possible combinations within the list
 *
 *  INPUTS:
 *  polys   = [chooseable, INT64 or DOUBLE supported]
 *          list of polygons {p1, p2, ...}, each may be defined as
 *              ring [2 n],
 *              polygon {[2 n], ...}
 *              multi_polygon {{[2 n], ... }, ...}
 *
 *  method  = [int] or {[int], ... } single value or list of value with same number as
 *      joblists
 *          0 - Difference (RefPol - ClipPol)
 *          1 - Intersection (Default)
 *          2 - Xor
 *          3 - Union
 *  jobs = {{[int], ... }, ... } or [m n] list of lists with different size or matrix where
 *      each row is treated as a list of the same length, whereas each list contains the
 *      indices of polygons to be combined. If more than two polygons given in
 *      joblist, than iterative processing takes place whereas the result is
 *      combined with the third input polygon and so forth.
 *
 *  correct   = [bool] should the input arguments be corrected
 *  spike_diameter  = [double] spikes with < this bound will be removed
 *  grid_limit  = [double = 0] self touchings will be moved inside using this grid size
 *  progress_bar = [double seconds] print a progress bar with the percentage of jobs calculated
 *      every s seconds to track calculation
 *
 *  OUTPUTS:
 *  prhs = list of multi-polygons {{{[2 n], ... }, ...}, ...}
 *  optional:
 *  polygon_areas[a1,...] area of every output polygon
 *
 * Compilation:
 *  TO BE DONE
  *  (add -largeArrayDims mex option on 64-bit computer)
 * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
 * History
 *  Original: 19-Dec-2012
 **************************************************************************************/

#include "stdafx.h"

#include "../bpolyclip/bpolyclip.hpp"
#include <boost\chrono.hpp>

namespace bpolyclip_batch {

std::ostringstream err;

namespace fn_prhs {
enum names {
    POLYS           = 0,
    METHOD          = 1,
    JOBS            = 2,
    CORRECT         = 3,
    SPIKE_DIAMETER  = 4,
    GRID_LIMIT   = 5,
    PROGRESS_BAR    = 6
};
}

void output_usage()
{
    mexPrintf(
 "/*********************************************************************************************\n"
 "* MATLAB MEX LIBRARY bpolyclip_batch.dll                                                      \n"
 "*                                                                                             \n"
 "* EXPORTS:                                                                                    \n"
 "*  void bpolyclip(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])             \n"
 "*   whereas prhs = (ref_poly, clip_poly, method, correct, pt_merge_dist, spike_diameter)      \n"
 "*                                                                                             \n"
 "* PURPOSE: engine to compute boolean operations on list of polygons per default               \n"
 "*  the given method is applied to all possible combinations within the list                   \n"
 "*                                                                                             \n"
 "*  INPUTS:                                                                                    \n"
 "*  polys   = [chooseable, INT64 or DOUBLE supported]                                          \n"
 "*          list of polygons {p1, p2, ...}, each may be defined as                             \n"
 "*              ring [2 n],                                                                    \n"
 "*              polygon {[2 n], ...}                                                           \n"
 "*              multi_polygon {{[2 n], ... }, ...}                                             \n"
 "*                                                                                             \n"
 "*  method  = [int] or {[int], ... } single value or list of value with same number as         \n"
 "*      joblists                                                                               \n"
 "*          0 - Difference (RefPol - ClipPol)                                                  \n"
 "*          1 - Intersection (Default)                                                         \n"
 "*          2 - Xor                                                                            \n"
 "*          3 - Union                                                                          \n"
 "*  jobs = {{[int], ... }, ... } or [m n] list of lists with different size or matrix where    \n"
 "*      each row is treated as a list of the same length, whereas each list contains the       \n"
 "*      indices of polygons to be combined. If more than two polygons given in                 \n"
 "*      joblist, than iterative processing takes place whereas the result is                   \n"
 "*      combined with the third input polygon and so forth.                                    \n"
 "*                                                                                             \n"
 "*  correct   = [bool] should the input arguments be corrected                                 \n"
 "*  spike_diameter  = [double] spikes with < this bound will be removed                        \n"
 "*  grid_limit  = [double = 0] self touchings will be moved inside using this grid size        \n"
 "*  progress_bar = [double seconds] print a progress bar with the percentage of jobs calculated\n"
 "*      every s seconds to track calculation                                                   \n"
 "*                                                                                             \n"
 "*  OUTPUTS:                                                                                   \n"
 "*  prhs = list of multi-polygons {{{[2 n], ... }, ...}, ...}                                  \n"
 "*  optional:                                                                                  \n"
 "*  polygon_areas[a1,...] area of every output polygon                                         \n"
 "*                                                                                             \n"
 "* Compilation:                                                                                \n"
 "*  TO BE DONE                                                                                 \n"
 " *  (add -largeArrayDims mex option on 64-bit computer)                                       \n"
 "* Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>                                       \n"
 "* History                                                                                     \n"
 "*  Original: 19-Dec-2012                                                                      \n"
 "**********************************************************************************************\n"
    );
}

//struct bpo_options {
//    bpo_options() : is_correct(false), spike_diameter(0), is_progress_bar(false), grid_limit(0.0) {};
//    bool is_correct;
//    double spike_diameter;
//    bool is_progress_bar;
//    double grid_limit;
//};

//=========================Exported=========================//
template<typename ValueType>
void compute_matlab_input(int nlhs, mxArray *plhs[],
                          int nrhs, const mxArray *prhs[], mxClassID &id)
{
    typedef typename bpolyclip::bpoly_types<ValueType>::multipolygon_type multipolygon_type;
    // computeArray contains { ref_poly, clip_poly, method, correct, pt_merge_dist, spike_diameter }
    bpolyclip::bpolyclip_options bpo;
    bpo.clip_method = bpolyclip::UNKNOWN_METHOD;
    bool is_progress_bar = false;
    typedef boost::chrono::seconds seconds;
    //typedef boost::chrono::thread_clock::time_point time_point;
    typedef boost::chrono::system_clock::time_point time_point;
    seconds update_interval;
    time_point next_update;
    //boost::chrono::thread_clock::time_point start_timestamp = boost::chrono::thread_clock::now();
    boost::chrono::system_clock::time_point start_timestamp = boost::chrono::system_clock::now();

    if (nrhs > fn_prhs::CORRECT) {
        bpo.correct = mxGetScalar(prhs[fn_prhs::CORRECT]) != 0;
    }

    if (nrhs > fn_prhs::PROGRESS_BAR) {
        double interval = mxGetScalar(prhs[fn_prhs::PROGRESS_BAR]);
        update_interval = boost::chrono::duration_cast<seconds>((boost::chrono::duration<double>)interval);
        //next_update = boost::chrono::thread_clock::now() + update_interval;
        next_update = boost::chrono::system_clock::now() + update_interval;
        is_progress_bar = interval != 0;
    }

    if (nrhs > fn_prhs::SPIKE_DIAMETER) {
        bpo.spike_diameter = mxGetScalar( prhs[fn_prhs::SPIKE_DIAMETER] );
    }

    if (nrhs > fn_prhs::GRID_LIMIT) {
        bpo.grid_limit = mxGetScalar( prhs[fn_prhs::GRID_LIMIT] );
    }

    if (mxGetNumberOfElements(prhs[fn_prhs::METHOD]) == 1) {
        bpo.clip_method = bpolyclip::ClipMethods((int)mxGetScalar(prhs[fn_prhs::METHOD]));
    } else {
        err << "ClipMethods is not a scalar value";
        mexErrMsgTxt(err.str().c_str());
        return;
    };

    size_t num_polys = mxGetM(prhs[fn_prhs::POLYS]) > mxGetN(prhs[fn_prhs::POLYS]) ? mxGetM(prhs[fn_prhs::POLYS]) : mxGetN(prhs[fn_prhs::POLYS]);

    std::vector<multipolygon_type> polys;

    polys.resize(num_polys);

    for (size_t idp = 0; idp < num_polys; ++idp) {
        bpolyclip::read_multipolygon<ValueType> ( mxGetCell(prhs[fn_prhs::POLYS], idp), polys[idp], bpo);
    }

    size_t num_jobs = 0;
    bool is_cell_list = false;

    if (mxIsCell(prhs[fn_prhs::JOBS])) {
        num_jobs = mxGetM(prhs[fn_prhs::JOBS]) > mxGetN(prhs[fn_prhs::JOBS]) ? mxGetM(prhs[fn_prhs::JOBS]) : mxGetN(prhs[fn_prhs::JOBS]);
        is_cell_list = true;
    } else {
        num_jobs = mxGetM(prhs[fn_prhs::JOBS]);
    }

    mxArray *outArray = mxCreateCellMatrix(1, num_jobs);
    double *outAreas = NULL;

    // create matrix for areas
    if (nlhs > 1) {
        plhs[1] = mxCreateDoubleMatrix(1, num_jobs, mxREAL);
        outAreas = mxGetPr(plhs[1]);
    }

    float pct = 0;
    size_t num_jobpolys = 0;
    double *poly_list_head_ptr = NULL;

    if (!is_cell_list) {
        poly_list_head_ptr = mxGetPr(prhs[fn_prhs::JOBS]);
        num_jobpolys = mxGetN(prhs[fn_prhs::JOBS]);
    }

    for(size_t idj = 0; idj < num_jobs; ++idj) {
        double *poly_list_ptr = NULL;

        if (is_cell_list) {
            mxArray *jobArray = mxGetCell(prhs[fn_prhs::JOBS], idj);
            num_jobpolys = mxGetN(jobArray) > mxGetM(jobArray) ? mxGetN(jobArray) : mxGetM(jobArray);
            // compute first intersection
            poly_list_ptr = mxGetPr(jobArray);
        } else {
            poly_list_ptr = poly_list_head_ptr+idj; 
        }

        if (num_jobpolys < 2) {
            err << "Number of Polys is " << num_jobpolys << " which is less then 2 and not supported";
            mexErrMsgTxt(err.str().c_str());
        }

        multipolygon_type poly_tmp1, poly_tmp2;//, poly_tmp3, poly_tmp4;
        multipolygon_type *poly_clip = NULL;
        multipolygon_type *poly_ref = &polys[(int)poly_list_ptr[0] - 1];
        multipolygon_type *poly_cut = &poly_tmp2;

        for (size_t idp = 1; idp < num_jobpolys; ++idp) {

            // get next poly of joblist, beware of matlab indexing!!!
            if (is_cell_list){
                poly_clip = &polys[(int)poly_list_ptr[idp] - 1];}
            else {
                poly_clip = &polys[(int)poly_list_ptr[idp*num_jobs] - 1];
            }
            bpolyclip::clip_multipolygon<ValueType>(*poly_ref, *poly_clip, *poly_cut, bpo);
            poly_ref = poly_cut;
            poly_cut = poly_cut == &poly_tmp1 ? &poly_tmp2 : &poly_tmp1;
            bg::clear(*poly_cut);

            if (is_progress_bar) {
                /*boost::chrono::thread_clock::time_point temp_timestamp = boost::chrono::thread_clock::now();*/
                boost::chrono::system_clock::time_point temp_timestamp = boost::chrono::system_clock::now();

                if (temp_timestamp > next_update) {
                    next_update += update_interval;
                    pct = ((float)(idj * 100 )) / num_jobs;
                    seconds elapsed_sec = boost::chrono::duration_cast<seconds>(temp_timestamp - start_timestamp);
                    int_least64_t elapsed = elapsed_sec.count();

                    mexPrintf("%d sec elapsed, %d of %d jobs done(%g pct), %d of %d polys in job done, approx. %g sec remaining\n",
                        elapsed,        idj, num_jobs,      pct,     idp, num_jobpolys, ((double)elapsed*100) / pct - elapsed);
                    mexEvalString("drawnow;");
                    //if (!(pct % 10)) { mexPrintf("%d", pct / 10); }
                }
            }

        }

        mxArray *poly_out_matlab = bpolyclip::write_multipolygon<ValueType>(*poly_ref, id);
        mxSetCell(outArray, idj, poly_out_matlab);

        if (nlhs > 1) {
            outAreas[idj] = (double)bg::area(*poly_ref);
        }

        //// set pointer to next list of polygons
        //if (!is_cell_list) {
        //    poly_list_ptr = poly_list_ptr++;
        //}
    }

    if (is_progress_bar) { mexPrintf("10\n"); }

    plhs[0] = outArray ;
}


//=========================Exported=========================//
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    // correct relevant values
    if (nrhs < 3 || mxIsEmpty(prhs[fn_prhs::POLYS]) || mxIsEmpty(prhs[fn_prhs::METHOD]) || mxIsEmpty(prhs[fn_prhs::JOBS]) || (mxGetM(prhs[fn_prhs::METHOD]) > 1 && mxGetM(prhs[fn_prhs::METHOD]) != mxGetM(prhs[fn_prhs::JOBS])) ) {
        output_usage();
        return;
    }

    mxClassID id;
    const mxArray *p_ref = prhs[fn_prhs::POLYS];

    // determine value ids
    while(mxIsCell(p_ref)) {p_ref = mxGetCell(p_ref, 0);}

    id = mxGetClassID(p_ref);

    switch(id) {
        case mxDOUBLE_CLASS: {
            compute_matlab_input< double >(nlhs, plhs, nrhs, prhs, id);
        }
        break;

        case mxINT64_CLASS: {
            compute_matlab_input< int_least64_t >(nlhs, plhs, nrhs, prhs, id);
        }
        break;

        default
                : {
                err << "Format " << id << " is not supported";
                mexErrMsgTxt(err.str().c_str());
            }
    }
}
};
