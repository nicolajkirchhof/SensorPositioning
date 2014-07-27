function [ bpo_combined ] = combine( bpo , is_batch_processing)
%COMBINE( bpo , is_batch_processing) combines all bpolyclip options for batch 
%   or bpolyclip computation
%   
if nargin < 2
    is_batch_processing = false;
end

if ~is_batch_processing
    bpo_combined =  {bpo.check, bpo.spike_distance, bpo.grid_limit, bpo.verbose};
else
    bpo_combined =  {bpo.check, bpo.spike_distance, bpo.grid_limit, bpo.verbose};
end

