 % /**************************************************************************************
 % * MATLAB MEX LIBRARY polypartition.mexw64
 % *
 % * EXPORTS:
 % *  void mexFunction(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
 % *   whereas prhs = (poly, method)
 % *
 % * PURPOSE: computes a polygon partitioning
 % *
 % *  INPUTS:
 % *  poly = [DOUBLE values]
 % *          ring [2 n],
 % *          polygon {[2 n], [...]}
 % *          multi_polygon {{[2 n], [...]}{...}}
 % *
 % *  method  = [int]
 % *          0 - Triangulation by ear clipping
 % *          1 - Optimal triangulation in terms of edge length using dynamic programming algorithm
 % *          2 - Triangulation by partition into monotone polygons
 % *          3 - Convex partition using Hertel-Mehlhorn algorithm
 % *          4 - Optimal convex partition using dynamic programming algorithm by Keil and Snoeyink
 % *
 % *  OUTPUTS: list of convex polygons
 % *  prhs {[2 n], [...]}
 % *
 % * Compilation:
 % *  TO BE DONE
 % *  >> mex -O -v polypartion_matlab.cpp
 % *  (add -largeArrayDims mex option on 64-bit computer)
 % * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
 % * History
 % *  Original: 19-Dec-2012
 % **************************************************************************************/