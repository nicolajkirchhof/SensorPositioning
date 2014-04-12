function [angles] = triangleAngles(bring)
%polygonArea for boost polygon
if nargin < 1
    angles = [];
    return;
end
dring = double(bring);
%%
P1 = dring(:,1)';
P2 = dring(:,2)';
P3 = dring(:,3)';
angles = [atan2(abs(det([P2-P1;P3-P1])),dot(P2-P1,P3-P1)), ...
         atan2(abs(det([P3-P2;P1-P2])),dot(P3-P2,P1-P2)), ...
        atan2(abs(det([P1-P3;P2-P3])),dot(P1-P3,P2-P3))];

