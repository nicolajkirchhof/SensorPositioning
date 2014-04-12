function [ ref_values, pixval, sensors, aoas, pos_estimates ] = createTestCase( numSamples, walkStd, walk,  sensor_pose, debug )
%CREATETESTCASE Summary of this function goes here
%   Detailed explanation goes here

if nargin < 5
    debug = false;
end

import Syscal.Example.Tools.*
import ThILo.Detail.Model.Sensor.StCartesian.*
if nargin < 4 || isempty(sensor_pose)
    load defaultPose;
    sensor_pose = pose;
end
if nargin < 3 || isempty(walk)
    load defaultQuadWalk
end
sample_positions = createRandomSamplesFromWalk(walk, walkStd, numSamples);

pixval = {};
aoas = {};
pos_estimates = {};
sensors = {};
for idx_sensor = 1:size(sensor_pose, 1)
    sobj = StCartesian;
    sobj.Position = sensor_pose(idx_sensor,1:3)';
    sobj.Orientation = sensor_pose(idx_sensor, 4:6)';
    sobj.StateIdx = [1 2];
    sensors{idx_sensor} = sobj;
    for idx_measure = 1:numSamples;
        reference = sample_positions(idx_measure, :)';
        if sobj.isInFov(reference)
            pixval_normalized = sobj.evaluate(reference);
            [aoa, pos_estimate] = Syscal.Detail.Tools.ExtractAoaFromLikelihood(sobj, pixval_normalized, reference, false); 
            aoas{idx_sensor, idx_measure} = aoa;
            pos_estimates{idx_sensor, idx_measure} = pos_estimate;
            pixval{idx_sensor, idx_measure} = pixval_normalized;
            if debug
                plotCalculation(sobj, reference, pixval_normalized, aoa, pos_estimate);
                pause;
            end
        else
            pixval{idx_sensor, idx_measure} = [];
        end
    end
end

ref_values(:, 1:2) = sample_positions;
ref_values(:, 3:6) = 0;

end

function plotCalculation(sobj, reference, pixval_normalized, aoa, pos_estimate)
% filter = ThILo.Detail.PreProcessor.AoaExtractor;
% filter.Sensor = sobj;
% %aoas = filter.apply(pixval_normalized);
% [aoa, pos_estimate] = Syscal.Detail.Tools.ExtractAoaFromLikelihood(sobj, pixval_normalized, reference);
disp(Mltools.rad2deg(atan2((reference(2)-sobj.Position(2)),(reference(1)-sobj.Position(1)))-sobj.Orientation(3)))
disp(Mltools.rad2deg(aoa))

cla
plot(sobj.Position(1,1), sobj.Position(2,1), 'ro');
hold on;
plot(reference(1,1), reference(2, 1), 'bx');
plot(pos_estimate(1,1), pos_estimate(2,1), 'go');

for i = 1:2:numel(aoa)
    %draw line from x=0 to x=7
    % fast hack for right angle summation
    position(1,1) = 0;
    position(2,1) = tan(sobj.Orientation(3,1)+aoa(1, i)) * (position(1,1)-sobj.Position(1,1)) + sobj.Position(2,1);
    position(1,2) = 6;
    position(2,2) = tan(sobj.Orientation(3,1)+aoa(1, i)) * (position(1,2)-sobj.Position(1,1)) + sobj.Position(2,1);
    line(position(1,:)', position(2,:));
end
axis([-1 6 -1 6]);
end

function [ self ] = createTplSensorState( pose )
%CREATETPLSENSORSTATE Summary of this function goes here
%   Detailed explanation goes here
self.StateIdx = 1:3;%1:5;
%self.StateLen = 5;
pt = 48/7 .* pi/180;
self.twist = (-(3.5*pt):pt:(3.5*pt));
self.Variance = eye(8,8);
self.Mean = zeros(8,1);

if nargin < 1
    self.x_ = 0;
    self.y_ = 0;
    self.phi_ = 0;
else
    self.x_ = pose(1,1);
    self.y_ = pose(2,1);
    self.phi_ = pose(3,1);
end

self.fullFovX_ = [-28; 28].* pi/180;
self.fullFovY_ = [0; 0]   .* pi/180;
%self.pixelFullFovX_ = [-4;4].*pi/180;
self.defaultRadius_ = 0.20;
self.b = 23.3626;
self.c = 0.5050;
%self.a = 1/(pi*self.b); %% choose such das everythings sums to one over the fov
self.a =  1./(self.b.* (atan(self.b.* (self.fullFovX_(2))) -  atan(self.b.* (self.fullFovX_(1)))));
%This is not correct the normalizer must be chosen, such that it equals one if the whole object is seen by a pixel
end


