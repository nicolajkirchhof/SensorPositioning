function wss_solution(pc, sol)
%%
s.x = zeros(pc.problem.num_sensors, 1);
s.ax = sol.ax;
sensors = pc.problem.sc_idx(sol.x>0, :);
usensors = unique(sensors);
s.x(usensors) = 1;
%%
% for ids = usensors(:)'
% s.ax(ids) = sum(sum(sensors == ids));
% end
draw.ws_solution(pc, s);