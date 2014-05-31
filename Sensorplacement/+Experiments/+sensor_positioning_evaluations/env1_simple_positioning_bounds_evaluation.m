%example for sensor positioning calculation
%% %Clear the desk

% clearvars *
format long;
is_display = true;
%init log
write_log(1) % print to standard output;
% write_log() % print to log_time.log output;
%generate the workspace

pc = calculate_solution_properties(pc);

%% plot solution
figure, draw_cplex_solution(pc);
figure, draw_sensor_point_correspondences(pc);
% return;
%% Evaluations
% pc = calculate_solution_goodness(pc);
% figure; plot_poly_contour(pc.solution.areas_not_covered); title(sprintf('Areas not covered sum = %f', pc.solution.area_not_covered));
%%
% figure; boxplot(pc.solution.q_ang , 'plotstyle','compact', 'symbol', ''); 
% title('Triangulation quality measure');
% figure; boxplot(pc.solution.q_lat' , 'plotstyle','compact', 'symbol', '');
% title('Trilateration quality measure');
%%
% figure; 
% boxplot(pc.solution.q_dist(:) , 'plotstyle','compact', 'symbol', ''); 
% set(gca,'XTickLabel',{' '}); 
% title('Distance from sensor to points');
%%

