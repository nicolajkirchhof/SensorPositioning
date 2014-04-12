
#include "stdafx.h"
#include "bpolyclip.hpp"

#ifndef NO_MATLAB
void mexFunction(int nlhs, mxArray *plhs[],
                           int nrhs, const mxArray *prhs[])
{
    bpolyclip::bpolyclip(nlhs, plhs, nrhs, prhs);
}
#endif
