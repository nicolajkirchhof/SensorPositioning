close all; 
clear all;
xpos = 100:25:250;
S = [xpos; ones(size(xpos))*100];
dmax = (100^2)/5;
[px, py] = meshgrid(50:300, 40:160);
p = [px(:)';py(:)'];
%%%
% for ids = 2:numel(S(1,:))
for ids = 6
% for idw = 1:pc.problem.num_positions
%     %%
%     idc = pc.problem.wp_sc_idx(:, idw);
%     idc = logical(idc);
%     s1_idx = pc.problem.sc_idx(idc,1);
%     s2_idx = pc.problem.sc_idx(idc,2);
s1_idx = 1;
s2_idx = ids;
v_s1_s2_2 = 0.5*diff(S(1:2,[s1_idx,s2_idx]), 1,2);
p_middle = S(1:2,[s1_idx])+ v_s1_s2_2;
v_up = [0; norm(v_s1_s2_2)*tan(0.15)];
    %%%
    q_sin = sin(mb.angle3PointsFast(S(1:2, s1_idx), p, S(1:2, s2_idx)))';    
%     ds1 = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, s1_idx))';
    ds1 = sqrt(sum(bsxfun(@minus, S(1:2, s1_idx), p).^2, 1))';
%     ds2 = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, s2_idx))';
    ds2 = sqrt(sum(bsxfun(@minus, S(1:2, s2_idx), p).^2, 1))';
    %%%
    % distance is mapped to 1-2
    qvals = q_sin./(1+(ds1.*ds2/dmax));
% end
z = reshape(qvals, size(px));
% mesh(px, py, z)
zcl = z;
% zcl(zcl<0.3) = 0;
figure,
title(sprintf('S1 = (%d %d), S2 = (%d %d)', S(1:2, s1_idx), S(1:2, s2_idx)));
% num_columns = numel(S(1,:))-1;
num_columns = 1;
idr = 1;
% idr = ids-1;
subplot(3,num_columns,idr);
hold on;
axis equal
% scatter(px(:),py(:),[],zcl(:));
% imagesc(flipud(px(1,:)'),py(:,1),zcl);
xlim([50 300]);
ylim([50 150]);
% contour(px,py,zcl, [0:0.05:1]);
% scatter(px(:),py(:),[],zcl(:));
surf(px, py, zcl);
plot(S(1,[s1_idx, s2_idx]), S(2,[s1_idx, s2_idx]));
plot([S(1,s1_idx) S(1,s1_idx)], [S(2,s1_idx)-50, S(2,s1_idx)+50]);
plot([S(1,s2_idx) S(1,s2_idx)], [S(2,s2_idx)-50, S(2,s2_idx)+50]);
drawEdge([p_middle', p_middle'+v_up']);

subplot(3,num_columns,idr+num_columns)
axis equal
hold on;
xlim([50 300]);
ylim([50 150]);
m_sin = reshape(q_sin, size(px));
contour(px,py,m_sin, 0.1*(1:10*pi/2));
plot(S(1,[s1_idx, s2_idx]), S(2,[s1_idx, s2_idx]));
plot([S(1,s1_idx) S(1,s1_idx)], [S(2,s1_idx)-50, S(2,s1_idx)+50]);
plot([S(1,s2_idx) S(1,s2_idx)], [S(2,s2_idx)-50, S(2,s2_idx)+50]);
drawEdge([p_middle', p_middle'+v_up']);

subplot(3,num_columns,idr+2*num_columns)
axis equal
hold on;
xlim([50 300]);
ylim([50 150]);
contour(px,py,reshape((1+(ds1.*ds2/dmax)), size(px)), 0.1*(1:5:100));
plot(S(1,[s1_idx, s2_idx]), S(2,[s1_idx, s2_idx]));
plot([S(1,s1_idx) S(1,s1_idx)], [S(2,s1_idx)-50, S(2,s1_idx)+50]);
plot([S(1,s2_idx) S(1,s2_idx)], [S(2,s2_idx)-50, S(2,s2_idx)+50]);
drawEdge([p_middle', p_middle'+v_up']);

% for ang = linspace(-pi/2, pi/2, 18)
%     drawRay(createRay(S(:,s1_idx)', ang), 'color', 'y');
%     drawRay(createRay(S(:,s2_idx)', ang+pi), 'color', 'm');
% end




end