function read_all_solutions
addpath('\\ds6\Measurements\Optimization\solutions\irf_seminar');
fsol = dir('\\ds6\Measurements\Optimization\solutions\irf_seminar\*.sol');
%%
addpath('\\ds6\Measurements\Optimization\solutions\P1_01_excerpt');
fsol = dir('\\ds6\Measurements\Optimization\solutions\P1_01_excerpt\*.sol');

%%
% matlabpool open
% for ids = 1:numel(fsol)
for ids = a:b
    fullname = which(fsol(ids).name);
    
    matfullname = strrep(fullname, '.sol', '.mat');
    if ~exist(matfullname, 'file')
        fprintf(1, '---- %s -----\n', fullname);
     sol = solver.cplex.read_solution_it(fullname);
%      iSaveX(matfullname, sol);
        save(matfullname, 'sol');
    end 
end
% matlabpool close

end