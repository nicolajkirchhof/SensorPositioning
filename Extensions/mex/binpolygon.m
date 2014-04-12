% /************************************************************************************** 
%  * MATLAB MEX LIBRARY bpolyclip_batch.dll												 
%  *																						 
%  * EXPORTS:																			 
%  *  [in on] mexFunction(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[]) 
%  *   whereas prhs = (points, poly, tol, hulltest)										 
%  *																						 
%  * PURPOSE: engine to compute if point(s) are located within a polygon (with holes)	 
%  *																						 
%  *  INPUTS:																			 
%  *  point(s) = [2 n] [chooseable, INT64 or DOUBLE supported]							 
%  *  poly     = [chooseable, INT64 or DOUBLE supported, must be same type as Points]	 
%  *              ring [2 n],															 
%  *              polygon {[2 n], ...}													 
%  *              multi_polygon {{[2 n], ... }, ...}										 
%  *																						 
%  *  tol  = [double] single value that states the tol to which point is considered 		 
%  *		to be on a line																	 
%  *																						 
%  *  OUTPUTS:																			 
%  *  in = logical[1 n] points in or on polygon											 
%  *  optional:																			 
%  *  on = logical[1 n] points on polygon												 
%  *																						 
%  * Compilation:																		 
%  *  >> matlab_install.m																 
%  * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>								 
%  * History																				 
%  *  Original: 19-Dec-2012																 
%  **************************************************************************************/