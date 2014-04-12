% /**************************************************************************************
 % * MATLAB MEX LIBRARY bpolyclip_batch.dll
 % *
 % * EXPORTS:
 % *  void bpolyclip(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
 % *   whereas prhs = (ref_poly, clip_poly, method, correct, pt_merge_dist, spike_diameter)
 % *
 % * PURPOSE: engine to compute boolean operations on list of polygons per default
 % *  the given method is applied to all possible combinations within the list
 % *
 % *  INPUTS:
 % *  polys   = [chooseable, INT64 or DOUBLE supported]
 % *          list of polygons {p1, p2, ...}, each may be defined as
 % *              ring [2 n],
 % *              polygon {[2 n], ...}
 % *              multi_polygon {{[2 n], ... }, ...}
 % *
 % *  method  = [int] or {[int], ... } single value or list of value with same number as
 % *      joblists
 % *          0 - Difference (RefPol - ClipPol)
 % *          1 - Intersection (Default)
 % *          2 - Xor
 % *          3 - Union
 % *  jobs = {{[int], ... }, ... } or [m n] list of lists with different size or matrix where
 % *      each row is treated as a list of the same length, whereas each list contains the
 % *      indices of polygons to be combined. If more than two polygons given in
 % *      joblist, than iterative processing takes place whereas the result is
 % *      combined with the third input polygon and so forth.
 % *
 % *  correct   = [bool] should the input arguments be corrected
 % *  spike_diameter  = [double] spikes with < this bound will be removed
 % *  grid_limit  = [double = 0] self touchings will be moved inside using this grid size
 % *  progress_bar = [double seconds] print a progress bar with the percentage of jobs calculated
 % *      every s seconds to track calculation
 % *
 % *  OUTPUTS:
 % *  prhs = list of multi-polygons {{{[2 n], ... }, ...}, ...}
 % *  optional:
 % *  polygon_areas[a1,...] area of every output polygon
 % *
 % * Compilation:
 % *  TO BE DONE
  % *  (add -largeArrayDims mex option on 64-bit computer)
 % * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
 % * History
 % *  Original: 19-Dec-2012
 % **************************************************************************************/