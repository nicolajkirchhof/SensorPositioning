function ws_wp_solstats(pc, sol)

figure, hold on;
sz = {3, 2};
subplot(sz{:},[1 2])
s_idx = 1:pc.problem.num_sensors;
plot(s_idx,sol.x(s_idx), '.r');
subplot(sz{:}, [3 4])
c_idx = pc.problem.num_sensors+pc.problem.num_positions+(1:pc.problem.num_comb);
plot(c_idx,sol.x(c_idx), '.g');
subplot(sz{:},5)
w_idx = pc.problem.num_sensors+(1:pc.problem.num_positions);
plot(w_idx,sol.x(w_idx), '.b', 'MarkerSize', 20);
subplot(sz{:},6)
hold on;
boxplot(sol.x(w_idx));