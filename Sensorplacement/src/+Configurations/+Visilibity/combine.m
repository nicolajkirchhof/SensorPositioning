function [ visi_combined ] = combine( visi )
%COMBINE( bpo , is_batch_processing) combines all bpolyclip options for batch 
%   or bpolyclip computation

visi_combined =  {visi.spike_distance, visi.eps, visi.verbose};
