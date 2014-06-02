function drawSensorPose(sp)
%% DRAWSENSORPOSE(sp) draws one or more sensor poses given in [3 n] array

hold on;
drawPoint(sp(1:2',:)', 'marker', '*' );
ray = createRay(sp(1:2, :)', sp(3, :)');
ray(:,3:4) = bsxfun(@plus, ray(:,1:2), ray(:,3:4)*1000);
drawEdge(ray, 'color', 'k');