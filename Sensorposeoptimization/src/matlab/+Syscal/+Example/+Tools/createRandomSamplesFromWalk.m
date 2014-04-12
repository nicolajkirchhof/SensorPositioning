function [ samples ] = createRandomSamplesFromWalk( walk, walkStd, numSamples )
%GETCREATERANDOMSAMPLES Summary of this function goes here
%   Detailed explanation goes here
% walk = [x1 y1; x2 y2; ... ;]
% ->walkStd        X
% | x1,y1  ...X..........X......... x2,y2
% -                            X

ts = timeseries(walk);
lnsp = linspace(ts.Time(1), ts.time(end), numSamples);
ts = ts.resample(lnsp);

samples = ts.data;
noise = randn(numSamples,2)*walkStd;
samples = bsxfun(@plus, samples, noise);

end

