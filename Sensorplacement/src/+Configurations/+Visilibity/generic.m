function visi = generic()
%% BPOLYCLIP_OPTIONS has all options that are passed to bpolyclip
% options may contain :
% check          = true  : if inputs shall be checked for orientation ...
% spike_distance = 0     : the spike distance that is used when merging polygons
% verbose        = false : if additional output is to be printed
% eps            = 1     : the epsilon at which points are merged into the env.

% visi.check          = true;
visi.spike_distance = 10;
visi.verbose        = false;
visi.eps            = 10;
% visi.grid_limit     = 1;

% bpo.fct_combine = @(bpo) {bpo.check, bpo.spike_distance, bpo.verbose, bpo.grid_limit};