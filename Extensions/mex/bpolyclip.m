% /**************************************************************************************
 % * MATLAB MEX LIBRARY bpolyclip_lib.dll
 % *
 % * EXPORTS:
 % *  void bpolyclip(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
 % *   whereas prhs = (ref_poly, clip_poly, method, check, pt_merge_dist, spike_diameter)
 % *
 % * PURPOSE: engine to compute boolean operations on two polygons
 % *
 % *  INPUTS:
 % *  ref_poly, clip_poly = [chooseable, INT64 or DOUBLE supported]
 % *          ring [2 n],
 % *          polygon {[2 n], [...]}
 % *          multi_polygon {{[2 n], [...]}{...}}
 % *
 % *  method  = [int]
 % *          0 - Difference (RefPol - ClipPol)
 % *          1 - Intersection (Default)
 % *          2 - Xor
 % *          3 - Union
 % *  check   = [bool = false] should the input arguments be checked
 % *  spike_diameter  = [double = 0] spikes with < lower then this bound will be removed
 % *  grid_limit  = [double = 0] self touchings will be moved inside using this grid size
 % *
 % *  OUTPUTS:
 % *  prhs {{[2 n], [...]}{...}}
 % * Compilation:
 % *  TO BE DONE
 % * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
 % * History
 % *  Original: 19-Dec-2012
 % **************************************************************************************/