H = [-(yu-y1)/r1^2 (xu-x1)/r1^2; -(yu-y2)/r2^2 (xu-x2)/r2^2];
syms xu x1 x2 yu y1 y2 r1 r2 dxu dyu H r real
r1 = sqrt((xu-x1)^2+(yu-y1)^2);
r2 = sqrt((xu-x2)^2+(yu-y2)^2);
H = [-(yu-y1)/r1^2 (xu-x1)/r1^2; -(yu-y2)/r2^2 (xu-x2)/r2^2];
gdop(xu, yu, x1, y1, x2, y2) = sqrt(trace(inv(H'*H)));
%%

gdop3 = @(xu, yu, x1, y1, x2, y2) prod(distancePoints([xu, yu], [[x1, y1];[x2,y2]]),2)'./sin(mod(mb.angle3PointsFast([x1; y1], [xu'; yu'], [x2; y2]), pi));
gdop2 = @(xu, yu, x1, y1, x2, y2) prod(distancePoints([xu, yu], [[x1, y1];[x2,y2]]))/sin(mod(angle3Points([x1, y1], [xu, yu], [x2,y2]), pi));