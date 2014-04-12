function [ pc ] = coverage( pc )
%COVERAGE Summary of this function goes here
%   Detailed explanation goes here

%% compute all sensor intersections to get valid sensorcombs
scomb = comb2unique(1:pc.problem.num_sensors);

pint = bpolyclip_batch(pc.problem.V, 1, scomb, pc.common.bpolyclip_batch_options{:});
pint_flt = ~cellfun(@isempty, pint);

pint_sel = pint(pint_flt);
scomb_sel = scomb(pint_flt, :);
s_unique = unique(scomb_sel(:))';
Sxy_unique = unique(pc.problem.S(1:2,s_unique)', 'rows', 'sorted')';

switch pc.quality.selected.name 
    case pc.quality.wss_dd_dop.name
        Sxy_polys

    otherwise
        error('not implemented');
end
end

function poly = dd_dop_phull(S1, S2, qm, dm, step)
%%
x1 = S1(1);
y1 = S1(2);
x2 = S2(1);
y2 = S2(2);
%%
  x1 = 1.0e2;
  x2 = 250;
  y1 = 1.0e2;
  y2 = 1.0e2;
  dm = 2.0e3;
  qm = 3.0e-1;
  step = 1;

% syms b a y1 y2 x1 x2 dm q(a, b) qm real
syms b a q(a, b) qb(b) real
assumeAlso(a >= 0 & b >= 0 & dm > 0 & qm > 0);
q(a,b) = (b*dm*sqrt(abs(x1-x2)^2+abs(y1-y2)^2))/(((a-sqrt(abs(x1-x2)^2+abs(y1-y2)^2)*(1.0/2.0))^2+b^2)*((a+sqrt(abs(x1-x2)^2+abs(y1-y2)^2)*(1.0/2.0))^2+b^2));
qb(a) = solve(q(a,b)-qm, b, 'Real', true, 'IgnoreAnalyticConstraints', true);
a_evl = 0:step:sqrt(abs(x1-x2)^2+abs(y1-y2)^2);
pt = arrayfun(@(ax) double(qb(ax)), a_evl, 'uniformoutput', false);
pt_flt = ~cellfun(@isempty, pt);
a_evl_sel = a_evl(pt_flt);
pt_sel = sort(cell2mat(pt(pt_flt)'), 2);
%%
if a_evl_sel(1) == 0
    poly_half1 = [a_evl_sel(:), pt_sel(:,1); flipud(a_evl_sel(:)), flipud(pt_sel(:,2))];
    poly_half2 = [-a_evl_sel(:), pt_sel(:,2); flipud(-a_evl_sel(:)), flipud(pt_sel(:,1))];
    poly = [poly_half1;poly_half2];
else
    poly1 = [a_evl_sel(:), pt_sel(:,1); flipud(a_evl_sel(:)), flipud(pt_sel(:,2))];
    poly2 = [-a_evl_sel(:), pt_sel(:,2); flipud(-a_evl_sel(:)), flipud(pt_sel(:,1))];
    poly = {poly1, poly2};
end
end