% /**************************************************************************************
% * MATLAB MEX LIBRARY visilibity.mexw64
% *
% * EXPORTS:
% *  void mexFunction(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
% *   whereas prhs = (points, poly, epsilon)
% *
% * PURPOSE: computes a polygon visibility_polygoning
% *
% *  INPUTS:
% *  points = [DOUBLE or INT64 values] will be cast into double values
% *          [2 n] Matrix of points
% *  poly = [DOUBLE or INT64 values] will be cast into double values
% *          ring [2 n],
% *          polygon {[2 n], [...]}
% *          multi_polygon {{[2 n], [...]}{...}}
% * epsilon = double accuracy
% *
% *  OUTPUTS: list of simple visibility polygons
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