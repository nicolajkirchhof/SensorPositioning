function [ scal ] = loadTestCase( name )
%LOADTESTCASE Summary of this function goes here
%   Detailed explanation goes here

p = mfilename('fullpath');
p = fileparts(p);

if nargin < 1
    disp('Testcases:');
    dir([p '/../../res/mat/tc*.mat']);
    return;
end

    vars = load(name, 'scal');
    scal = vars.scal;

end

