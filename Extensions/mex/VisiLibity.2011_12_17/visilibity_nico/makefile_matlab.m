%Build for matlab
mex -c visilibity.cpp visilibity.o
mex -v visibility_graph.cpp visilibity.o
mex -v visibility_polygon.cpp visilibity.o
mex -v shortest_path.cpp visilibity.o
mex -v in_environment.cpp visilibity.o

