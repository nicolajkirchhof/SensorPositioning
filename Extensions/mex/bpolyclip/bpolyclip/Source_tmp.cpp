
void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[] )
{
	typedef boost::geometry::model::polygon<boost::geometry::model::d2::point_xy<double>, false, false > polygonccw;
	polygon ref, clip;

	    //if (nrhs == 0) {
     //   mexPrintf("OutPol = clipper(RefPol, ClipPol, Method, Scale);\n");
     //   mexPrintf(" Clips polygons by Method:\n");
     //   mexPrintf("  0 - Difference (RefPol - ClipPol)\n");
     //   mexPrintf("  1 - Intersection\n (Default)");
     //   mexPrintf("  2 - Xor\n");
     //   mexPrintf("  3 - Union\n");
     //   mexPrintf(" Scales all values to Int64 by Scale:\n");
     //   mexPrintf(" Default = 1d\n");
     //   mexPrintf("All polygons are structures with the fields ...\n");
     //   mexPrintf("  .x:    x-coordinates of contour\n");
     //   mexPrintf("  .y:    y-coordinates of contour\n");
     //   mexPrintf("  .hole:    defines if contour is a hole\n");        
     //   mexPrintf("All polygons may contain several contours.\n");
     //   mexPrintf("\nPolygon Clipping Routine based on clipper v4.8.8.\n");
     //   mexPrintf(" Credit goes to Angus Johnson\n");
     //   mexPrintf(" http://www.angusj.com/delphi/clipper.php\n\n");
     //   return;}

	if (nrhs != 3)
		mexErrMsgTxt("Error wrong number of input arguments");

	int num_points = mxGetM(prhs[0]);
	for (unsigned i = 0; i < num_points; i++)
	{
		
	}


  //Construct environment
  //Passing structures and cell arrays into MEX-files is just like
  //passing any other data types, except the data itself is of type
  //mxArray. In practice, this means that mxGetField (for structures)
  //and mxGetCell (for cell arrays) return pointers of type
  //mxArray. You can then treat the pointers like any other pointers
  //of type mxArray, but if you want to pass the data contained in the
  //mxArray to a C routine, you must use an API function such as
  //mxGetData to access it.
  //
  //Find the dimensions of input.
  //int m = mxGetM(prhs[1]);
  //int n = mxGetN(prhs[1]);


  //Auxiliary vars
  //Recall const My_type *my_ptr => my_ptr points to a constant of
  //type My_type, i.e., my_ptr is not a constant pointer to a variable
  //of type My_type.
  const mxArray *polygon_ptr;
  int num_of_coords;
  //coord_ptr is indexable, e.g., my_coord[0] returns the x
  //coordinate of the first vertex.
  const double *coord_ptr;
  std::vector<VisiLibity::Point> vertices;
  VisiLibity::Polygon polygon_temp;


  //Outer Boundary
  polygon_ptr = mxGetCell(prhs[1], 0);
  num_of_coords = mxGetM(polygon_ptr);
  //mexPrintf("The outer boundary has %i vertices.\n", num_of_coords); 
  coord_ptr = mxGetPr( polygon_ptr );
  for(int j=0; j<num_of_coords; j++){
    vertices.push_back(  VisiLibity::Point( coord_ptr[j],
					    coord_ptr[num_of_coords + j] )  );
  }
  //VisiLibity::Environment my_environment( VisiLibity::Polygon(vertices) );
  polygon_temp.set_vertices(vertices);
  VisiLibity::Environment *my_environment;
  my_environment = new VisiLibity::Environment(polygon_temp);
  vertices.clear();


  //Holes
  //The number of polygons is the number of cells (one polygon
  //per cell).
  int num_of_polygons = mxGetNumberOfElements( prhs[1] );
  for(int i=1; i<num_of_polygons; i++){

    polygon_ptr = mxGetCell(prhs[1], i);
    num_of_coords = mxGetM(polygon_ptr);
    //mexPrintf("The hole #%i has %i vertices.\n", i, num_of_coords); 
    coord_ptr = mxGetPr( polygon_ptr );
    for(int j=0; j<num_of_coords; j++){
      vertices.push_back(  VisiLibity::Point( coord_ptr[j],
				  coord_ptr[num_of_coords + j] )  );
    } 
    
    polygon_temp.set_vertices( vertices );
    my_environment->add_hole( polygon_temp );
    //:COMPILER:
    //Why doesn't this work if my_environment were not a pointer?
    //my_environment.add_hole( polygon_temp );
    vertices.clear();
  }


  //Get robustness constant
  double epsilon = mxGetScalar(prhs[2]);
 

  //Adjust observer location according to snap distance
  double snap_distance = mxGetScalar(prhs[3]);
  if(  !observer.in( *my_environment , epsilon )  )
    observer = observer.projection_onto_boundary_of( *my_environment );
  observer.snap_to_vertices_of( (*my_environment) , snap_distance);
  observer.snap_to_boundary_of( (*my_environment) , snap_distance);
  //observer.snap_to_vertices_of( (*my_environment) , snap_distance);


  //Compute Visibility_Polygon
  VisiLibity::Visibility_Polygon my_vis_poly( observer,
					      (*my_environment),
					      epsilon);

  
  //Create an mxArray for the output
  plhs[0] = mxCreateDoubleMatrix( my_vis_poly.n(), 2, mxREAL );
  //Create a pointer to output
  double *out = mxGetPr(plhs[0]);
  //Populate the output
  for (int i=0; i<my_vis_poly.n(); i++){
    out[i]                   = my_vis_poly[i].x();
    out[my_vis_poly.n() + i] = my_vis_poly[i].y();
  }
 

  delete my_environment;

  return;
}
