%% Create Sample set
gt.params = WPNC_Dresden_2011.Parameters.Cartesian2D_ThILo_NoNoise;

gt.sensor.orientations = [ 67.5  22.5 157.5 112.5 -112.5 -157.5 -22.5 -67.5  ].* pi/180;
gt.sensor.positions = [ ...
    0.928 0  % 0 0
    0.928 0  % 0 0
    5.833 0 %4.9 4.9
    5.833 0 %4.9 4.9
    5.830 6.3780 % 4.9 6.18
    5.830 6.3780 % 4.9 6.18
    1.018 6.350  %0 6.18
    1.018 6.350  %0 6.18
    ];
gt.sensor.sensorReference= [gt.sensor.positions gt.sensor.orientations'];

gt.numMeasures = 50;
%%
% Create parameter sets

gt = getRandomPositionSensorValues(gt);
%%
gt.sensor.estimates = randomizeSensorPose(gt.sensor.pose, [0 0 0]);
gt = initOptimization(gt);
%%
save testcase gt

