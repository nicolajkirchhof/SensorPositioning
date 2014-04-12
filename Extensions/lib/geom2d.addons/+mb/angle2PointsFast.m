function theta = angle2PointsFast(p1, p2)
% fast calculation of 2 point angle, both must be double
dp = bsxfun(@minus,p2, p1);
theta = atan2(dp(2,:), dp(1,:));