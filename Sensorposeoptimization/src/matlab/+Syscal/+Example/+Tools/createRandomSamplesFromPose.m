function [ samples ] = createRandomSamplesFromPose( pose, numSamples )
%GETCREATERANDOMSAMPLES Summary of this function goes here
%   Detailed explanation goes here
    
      posediff = max(pose(:,1:2))-min(pose(:,1:2));
      
      samples = bsxfun(@plus, bsxfun(@times, posediff', rand(2,numSamples)), min(pose(:,1:2))'); 

end

