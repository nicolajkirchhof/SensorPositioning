sp = all_eval.large_flat.cmcqm_cmaes_it{51}.sol.discretization.sp;
input = Experiments.Diss.large_flat(0, 0);
opt_conf = Optimization.Continuous.prepare_opt(input, sp);
Optimization.Continuous.fitfct.cmcqm_nostat(opt_conf)
%%
sp = all_eval_full.office_floor.gco{51}.discretization.sp;
input = Experiments.Diss.office_floor(0, 0);
opt_conf = Optimization.Continuous.prepare_opt(input, sp);
Optimization.Continuous.fitfct.cmcqm_nostat(opt_conf)
all_eval.office_floor.cmcqm_cmaes_it{51}.solutions{1}

%%
sp = all_eval_full.small_flat.gco{51}.discretization.sp;
input = Experiments.Diss.small_flat(0, 0);
opt_conf = Optimization.Continuous.prepare_opt(input, sp);
100*(0.99-Optimization.Continuous.fitfct.cmcqm_nostat(opt_conf))
100*(0.99-all_eval.small_flat.cmcqm_cmaes_it{51}.solutions{1}.fmin)
100*(0.99-all_eval.small_flat.cmcqm_nonlin_it{51}.solutions{1}.fmin)