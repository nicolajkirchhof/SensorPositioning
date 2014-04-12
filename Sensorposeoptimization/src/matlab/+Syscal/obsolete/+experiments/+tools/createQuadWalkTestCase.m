function [ scal ] = createQuadWalkTestCase( numSamples, walkStd,  pose )
%CREATETESTCASE Summary of this function goes here
%   Detailed explanation goes here
    
    if nargin < 3
        load defaultPose;
    else
        load(pose);
    end
    
    load defaultQuadWalk;
    samples = syscal.createRandomSamplesFromWalk(walk, walkStd, numSamples);
    
    aoas = tplsim.simulatePose(pose, numSamples, samples);
    scal = syscal(size(pose,1), numSamples);  
    scal.setReferences(pose, samples);
      
    len = 0;
    for i = 1:size(aoas, 2)
        aiIdx = abs(aoas(:,i)) < mltools.deg2rad(22.5);
        scal.measureAoa{i,1} = aoas(aiIdx, i);
        scal.measureAssignment{i,1} = find(aiIdx);
        len = len+numel(scal.measureAoa{i,1});
    end
end

