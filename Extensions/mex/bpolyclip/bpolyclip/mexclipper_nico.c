// mex clipper.cpp mexclipper.cpp

#include <mex.h>
#include "booleng.h"


void read_polygons_MATLAB(const mxArray *prhs,  Bool_Engine* booleng, GroupType gr, double scale)
{
    int id_x, id_y, id_hole;
    size_t num_contours;
    size_t nx, ny;
    //long64 *x, *y;
    double *x, *y;
    double hole; 
    const mxArray *x_in, *y_in, *hole_in;
    
    /*  Checking if input is non empty Matlab-structure */
    if (!mxIsStruct(prhs))
        mexErrMsgTxt("Input needs to be structure.");
    if (!mxGetM(prhs) || !mxGetN(prhs))
        mexErrMsgTxt("Empty structure.");
    
    /*  Checking field names and data type  */
    id_x = mxGetFieldNumber(prhs,"x");
    if (id_x==-1)
        mexErrMsgTxt("Input structure must contain a field 'x'.");
    
    id_y = mxGetFieldNumber(prhs,"y");
    if (id_y==-1)
        mexErrMsgTxt("Input structure must contain a field 'y'.");
    
    id_hole = mxGetFieldNumber(prhs,"hole");
    if (id_hole==-1)
        mexErrMsgTxt("Input structure must contain a field 'hole'.");
    
    num_contours = mxGetNumberOfElements(prhs);
    for (unsigned i = 0; i < num_contours; i++){
        x_in = mxGetFieldByNumber(prhs, i, id_x);
        y_in = mxGetFieldByNumber(prhs, i, id_y);
        hole_in = mxGetFieldByNumber(prhs, i, id_hole);
        
        nx = mxGetNumberOfElements(x_in);
        ny = mxGetNumberOfElements(y_in);
        if (nx!=ny)
            mexErrMsgTxt("Structure fields x and y must be the same length.");
        
        //poly[i].resize(nx);
        x = (double*)mxGetData(x_in);
        y = (double*)mxGetData(y_in);
        
                if ( booleng->StartPolygonAdd( gr ) )
        {
        for (unsigned j = 0; j < nx; j++){
            booleng->AddPoint( x[j], y[j]);            
        } 
                }
                else
                    mexErrMsgTxt("Boolengine not ready");
        booleng->EndPolygonAdd();

        //hole = mxGetScalar(hole_in);
        //bool is_cw = Orientation(poly[i]);
        //if ((hole == 0.0 && is_cw) || (hole != 0.0 && !is_cw))
        //    {
        //        ReversePolygon(poly[i]);
        //    }
    }
}

void write_polygons_MATLAB(mxArray *plhs,  Bool_Engine* booleng, double scale)
{
    mxArray *x_out, *y_out, *hole_out;
    
     while ( booleng->StartPolygonGet() )
     {
         int size = booleng->GetNumPointsInPolygon();
         x_out = mxCreateDoubleMatrix(solution[i].size(),1,mxREAL);
        y_out = mxCreateDoubleMatrix(solution[i].size(),1,mxREAL);
      // foreach point in the polygon
      while ( booleng->PolygonHasMorePoints() )
      {
       fprintf(stdout,"x = %f\t", booleng->GetPolygonXPoint());
       fprintf(stdout,"y = %f\n", booleng->GetPolygonYPoint());
      }
      booleng->EndPolygonGet();
     }


    for (unsigned i = 0; i < solution.size(); ++i)
    {
        x_out = mxCreateDoubleMatrix(solution[i].size(),1,mxREAL);
        y_out = mxCreateDoubleMatrix(solution[i].size(),1,mxREAL);
        for (unsigned j = 0; j < solution[i].size(); ++j)
        {
            ((double*)mxGetPr(x_out))[j]=((double)solution[i][j].X)/scale;
            ((double*)mxGetPr(y_out))[j]=((double)solution[i][j].Y)/scale;
        }
        mxSetFieldByNumber(plhs,i,0,x_out);
        mxSetFieldByNumber(plhs,i,1,y_out);

        hole_out = mxCreateDoubleMatrix(1,1,mxREAL);
        ((double*)mxGetPr(hole_out))[0]=!Orientation(solution[i]);
        mxSetFieldByNumber(plhs,i,2,hole_out);
    }
}

void ArmBoolEng( Bool_Engine* booleng )
{
    // set some global vals to arm the boolean engine
    double DGRID = 1000;  // round coordinate X or Y value in calculations to this
    double MARGE = 0.001;   // snap with in this range points to lines in the intersection routines
    // should always be > DGRID  a  MARGE >= 10*DGRID is oke
    // this is also used to remove small segments and to decide when
    // two segments are in line.
    double CORRECTIONFACTOR = 500.0;  // correct the polygons by this number
    double CORRECTIONABER   = 1.0;    // the accuracy for the rounded shapes used in correction
    double ROUNDFACTOR      = 1.5;    // when will we round the correction shape to a circle
    double SMOOTHABER       = 10.0;   // accuracy when smoothing a polygon
    double MAXLINEMERGE     = 1000.0; // leave as is, segments of this length in smoothen


    // DGRID is only meant to make fractional parts of input data which
    // are doubles, part of the integers used in vertexes within the boolean algorithm.
    // Within the algorithm all input data is multiplied with DGRID

    // space for extra intersection inside the boolean algorithms
    // only change this if there are problems
    int GRID = 10000;

    booleng->SetMarge( MARGE );
    booleng->SetGrid( GRID );
    booleng->SetDGrid( DGRID );
    booleng->SetCorrectionFactor( CORRECTIONFACTOR );
    booleng->SetCorrectionAber( CORRECTIONABER );
    booleng->SetSmoothAber( SMOOTHABER );
    booleng->SetMaxlinemerge( MAXLINEMERGE );
    booleng->SetRoundfactor( ROUNDFACTOR );

}

void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    //Polygons subj, clip, solution;
    Bool_Engine* booleng = new Bool_Engine();
    const char *field_names[] = {"x","y","hole"};
    int ct = 1;
    mwSize dims[2];
    double scale = 1;

    // Probably
    ArmBoolEng( booleng );
    
    if (nrhs == 0) {
        mexPrintf("OutPol = clipper(RefPol, ClipPol, Method, Scale);\n");
        mexPrintf(" Clips polygons by Method:\n");
        mexPrintf("  0 - Difference (RefPol - ClipPol)\n");
        mexPrintf("  1 - Intersection\n (Default)");
        mexPrintf("  2 - Xor\n");
        mexPrintf("  3 - Union\n");
        mexPrintf(" Scales all values to Int64 by Scale:\n");
        mexPrintf(" Default = 1d\n");
        mexPrintf("All polygons are structures with the fields ...\n");
        mexPrintf("  .x:    x-coordinates of contour\n");
        mexPrintf("  .y:    y-coordinates of contour\n");
        mexPrintf("  .hole:    defines if contour is a hole\n");        
        mexPrintf("All polygons may contain several contours.\n");
        mexPrintf("\nPolygon Clipping Routine based on kbool 2.1\n");
        mexPrintf(" Credit goes to \n");
        mexPrintf("");
        return;}
    
    /*  Check number of arguments */
    
    if (nlhs != 1)
        mexErrMsgTxt("One output required.");
    
    if (nrhs < 2)
        mexErrMsgTxt("At least two polygons are needed.");
        
    if (nrhs >= 2)
    {
        if (nrhs > 2)
        {
            if(!mxIsDouble(prhs[2]) || mxGetM(prhs[2])!=1 || mxGetN(prhs[2])!=1)
                mexErrMsgTxt("Third input must be scalar.");
            else
                ct=(int)mxGetScalar(prhs[2]);
        }
        if (nrhs > 3)
            scale = mxGetScalar(prhs[3]);
        
        if (mxIsStruct(prhs[1]))
        {
            // Clip two input polygons
            BOOL_OP CT;            
            switch (ct){
                case 0:
                    CT=BOOL_A_SUB_B;
                    break;
                case 1:
                    CT=BOOL_AND;
                    break;
                case 2:
                    CT=BOOL_EXOR;
                    break;
                case 3:
                    CT=BOOL_OR;
                    break;
                default:
                    mexErrMsgTxt("Third input must be 0, 1, 2, or 3.");
            }


            
            /* Import polygons to structures */
            read_polygons_MATLAB(prhs[0], booleng, GROUP_A, scale);
            read_polygons_MATLAB(prhs[1], booleng, GROUP_A, scale);
            
            Clipper c;
            c.AddPolygons(subj, ptSubject);
            c.AddPolygons(clip, ptClip);
            
            if (c.Execute(CT, solution)){
                dims[0] = 1;
                dims[1] = solution.size();
                plhs[0] = mxCreateStructArray(2, dims, 3, field_names);
                write_polygons_MATLAB(plhs[0], solution, scale);
            } else
                mexErrMsgTxt("Clipper Error.");
        }
        //else
        //{
        //    // Offset single input polygon
        //    if (!mxIsDouble(prhs[1]) || mxGetM(prhs[1])!=1 || mxGetN(prhs[1])!=1)
        //        mexErrMsgTxt("Second input must be either a structure or a scalar double.");
        //    
        //    if (nrhs > 3)
        //        mexPrintf("Ignoring fill type arguments for offsetting.\n");
        //    
        //    /* Import polygons to structures */
        //    read_polygons_MATLAB(prhs[0], subj);
        //    
        //    JoinType jt;
        //    double delta, ml;
        //    
        //    delta=mxGetScalar(prhs[1]);
        //    ml=mxGetScalar(prhs[2]);
        //    
        //    if (ml==0)
        //        jt=jtRound;
        //    else if (ml==1)
        //        jt=jtSquare;
        //    else
        //        jt=jtMiter;
        //    
        //    OffsetPolygons(subj, solution, delta, jt, ml);
        //    dims[0] = 1;
        //    dims[1] = solution.size();
        //    plhs[0] = mxCreateStructArray(2, dims, 2, field_names);
        //    write_polygons_MATLAB(plhs[0], solution);
        //}
    }
    else
        mexErrMsgTxt("At least two inputs required.");
}

