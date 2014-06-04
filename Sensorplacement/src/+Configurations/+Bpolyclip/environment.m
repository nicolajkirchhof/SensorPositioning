function bpo = environment()
%% BPOLYCLIP_OPTIONS has all options that are passed to bpolyclip
% options may contain :
% check          = true  : if inputs shall be checked for orientation ...
% spike_distance = 0     : the spike distance that is used when merging polygons
% verbose        = false : if additional output is to be printed
% grid_limit     = 1     : the minimum grid limit used for processing

bpo = Configurations.Bpolyclip.generic;
bpo.check          = true;
bpo.spike_distance = 10;
bpo.verbose        = false;
bpo.grid_limit     = 1;
