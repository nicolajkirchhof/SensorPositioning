import Syscal.Example.Tools.*
num_samples = 30;
walk_std = 0.1;


walk_pose = load('defaultQuadWalk', 'walk');
walk_pose = walk_pose.walk;
sensor_pose = load('defaultPose', 'pose');
sensor_pose = sensor_pose.pose;

[ sample_positions, pixval, sensors ] = createTestCase( num_samples, walk_std, walk_pose,  sensor_pose );

sample_positions(:,3:6) = 0;
mp = Syscal.Parameters.Pose.MeasurementPose();
mp.pixval = pixval;
mp.reference = sample_positions;
mp.lb(:,1:2) = mp.reference(:,1:2)-1;
mp.ub(:,1:2) = mp.reference(:,1:2)+1;

mp.plot()





%%
