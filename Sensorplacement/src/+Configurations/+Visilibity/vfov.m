function visi = vfov()
%% vfov_options() has all options that are passed to bpolyclip
% options may contain :
% check          = true  : if inputs shall be checked for orientation ...
% spike_distance = 0     : the spike distance that is used when merging polygons
% verbose        = false : if additional output is to be printed
% eps            = 1     : the epsilon at which points are merged into the env.

visi = Configurations.Bpolyclip.generic;
visi.spike_distance = 10;
visi.verbose        = false;
visi.eps            = 10;