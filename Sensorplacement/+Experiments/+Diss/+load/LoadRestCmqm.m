
in = load('tmp\small_flat\cmqm\cmaes_it_500_150.mat');
in.solution.id_sp = in.solution.num_sp/10+1;
in.solution.id_wpn = in.solution.num_wpn/10+1;
in.solution.sol = in.solution.solutions{end-1};
in.solution.sensors_selected = 1:size(in.solution.sol.sp, 2);
in.solution.quality.sum_max = -in.solution.sol.fmin;
in.solution.all_wpn = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_wpn;
in.solution.all_sp = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_sp;           
all_eval.small_flat.cmqm_cmaes_it{in.solution.id_sp, in.solution.id_wpn} = in.solution;

in = load('tmp\small_flat\cmqm\cmaes_it_500_200.mat');
in.solution.id_sp = in.solution.num_sp/10+1;
in.solution.id_wpn = in.solution.num_wpn/10+1;
in.solution.sol = in.solution.solutions{end-1};
in.solution.sensors_selected = 1:size(in.solution.sol.sp, 2);
in.solution.quality.sum_max = -in.solution.sol.fmin;
in.solution.all_wpn = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_wpn;
in.solution.all_sp = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_sp;

all_eval.small_flat.cmqm_cmaes_it{in.solution.id_sp, in.solution.id_wpn} = in.solution;


in = load('tmp\small_flat\cmqm\cmaes_it_500_250.mat');
in.solution.id_sp = in.solution.num_sp/10+1;
in.solution.id_wpn = in.solution.num_wpn/10+1;
in.solution.sol = in.solution.solutions{end-1};
in.solution.sensors_selected = 1:size(in.solution.sol.sp, 2);
in.solution.quality.sum_max = -in.solution.sol.fmin;
in.solution.all_wpn = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_wpn;
in.solution.all_sp = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_sp;

all_eval.small_flat.cmqm_cmaes_it{in.solution.id_sp, in.solution.id_wpn} = in.solution;


in = load('tmp\small_flat\cmqm\cmaes_it_500_300.mat');
in.solution.id_sp = in.solution.num_sp/10+1;
in.solution.id_wpn = in.solution.num_wpn/10+1;
in.solution.sol = in.solution.solutions{end-1};
in.solution.sensors_selected = 1:size(in.solution.sol.sp, 2);
in.solution.quality.sum_max = -in.solution.sol.fmin;
in.solution.all_wpn = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_wpn;
in.solution.all_sp = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_sp;

all_eval.small_flat.cmqm_cmaes_it{in.solution.id_sp, in.solution.id_wpn} = in.solution;

in = load('tmp\small_flat\cmqm\cmaes_it_500_350.mat');
in.solution.id_sp = in.solution.num_sp/10+1;
in.solution.id_wpn = in.solution.num_wpn/10+1;
in.solution.sol = in.solution.solutions{end-1};
in.solution.sensors_selected = 1:size(in.solution.sol.sp, 2);
in.solution.quality.sum_max = -in.solution.sol.fmin;
in.solution.all_wpn = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_wpn;
in.solution.all_sp = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_sp;

all_eval.small_flat.cmqm_cmaes_it{in.solution.id_sp, in.solution.id_wpn} = in.solution;

in = load('tmp\small_flat\cmqm\cmaes_it_500_400.mat');
in.solution.id_sp = in.solution.num_sp/10+1;
in.solution.id_wpn = in.solution.num_wpn/10+1;
in.solution.sol = in.solution.solutions{end-1};
in.solution.sensors_selected = 1:size(in.solution.sol.sp, 2);
in.solution.quality.sum_max = -in.solution.sol.fmin;
in.solution.all_wpn = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_wpn;
in.solution.all_sp = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_sp;

all_eval.small_flat.cmqm_cmaes_it{in.solution.id_sp, in.solution.id_wpn} = in.solution;

in = load('tmp\small_flat\cmqm\cmaes_it_500_450.mat');
in.solution.id_sp = in.solution.num_sp/10+1;
in.solution.id_wpn = in.solution.num_wpn/10+1;
in.solution.sol = in.solution.solutions{end-1};
in.solution.sensors_selected = 1:size(in.solution.sol.sp, 2);
in.solution.quality.sum_max = -in.solution.sol.fmin;
in.solution.all_wpn = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_wpn;
in.solution.all_sp = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_sp;

all_eval.small_flat.cmqm_cmaes_it{in.solution.id_sp, in.solution.id_wpn} = in.solution;

in = load('tmp\small_flat\cmqm\cmaes_it_500_500.mat');
in.solution.id_sp = in.solution.num_sp/10+1;
in.solution.id_wpn = in.solution.num_wpn/10+1;
in.solution.sol = in.solution.solutions{end-1};
in.solution.sensors_selected = 1:size(in.solution.sol.sp, 2);
in.solution.quality.sum_max = -in.solution.sol.fmin;
in.solution.all_wpn = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_wpn;
in.solution.all_sp = all_eval.small_flat.gco{in.solution.id_sp, in.solution.id_wpn}.all_sp;

all_eval.small_flat.cmqm_cmaes_it{in.solution.id_sp, in.solution.id_wpn} = in.solution;
