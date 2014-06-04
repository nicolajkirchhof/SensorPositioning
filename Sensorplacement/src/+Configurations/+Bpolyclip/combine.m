function [ bpo_combined ] = combine( bpo , is_batch_processing)
%COMBINE( bpo , is_batch_processing) combines all bpolyclip options for batch 
%   or bpolyclip computation
%   
if nargin < 2
    is_batch_processing = false;
end

if ~is_batch_processing
    bpo_combined =  {bpo.check, bpo.spike_distance, bpo.verbose, bpo.grid_limit};
else
    bpo_combined =  {bpo.check, bpo.spike_distance, bpo.verbose, bpo.grid_limit, bpo.verbose};
end

