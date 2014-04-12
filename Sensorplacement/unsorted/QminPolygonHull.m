function poly = QminPolygonHull(S1, S2, qm, dm, step)
%%
x1 = S1(1);
y1 = S1(2);
x2 = S2(1);
y2 = S2(2);
%%
  x1 = 1.0e3;
  x2 = 2000;
  y1 = 1.0e3;
  y2 = 1.0e3;
  dm = 4e6;
  qm = 3.0e-1;
  step = 100;
  S1 = [x1, y1];
  S2 = [x2, y2];
  v12t = zeros(2,1);
  v12t(1,1) = -1.0/sqrt(abs(x1-x2)^2+abs(y1-y2)^2)*(y1-y2);
  v12t(2,1) = 1.0/sqrt(abs(x1-x2)^2+abs(y1-y2)^2)*(x1-x2);
  v12 = zeros(2,1);
  v12(1,1) = -1.0/sqrt(abs(x1-x2)^2+abs(y1-y2)^2)*(x1-x2);
  v12(2,1) = -1.0/sqrt(abs(x1-x2)^2+abs(y1-y2)^2)*(y1-y2);

% syms b a y1 y2 x1 x2 dm q(a, b) qm real
syms b a q(a, b) qb(b) real

assumeAlso(a >= 0 & b >= 0 & dm > 0 & qm > 0);
q(a,b) = (b*dm*sqrt(abs(x1-x2)^2+abs(y1-y2)^2))/(((a-sqrt(abs(x1-x2)^2+abs(y1-y2)^2)*(1.0/2.0))^2+b^2)*((a+sqrt(abs(x1-x2)^2+abs(y1-y2)^2)*(1.0/2.0))^2+b^2));
qb(a) = solve(q(a,b)-qm, b, 'Real', true, 'IgnoreAnalyticConstraints', true);
a_evl = 0:step:2*sqrt(abs(x1-x2)^2+abs(y1-y2)^2);
pt = arrayfun(@(ax) double(qb(ax)), a_evl, 'uniformoutput', false);
pt_flt = ~cellfun(@isempty, pt);
a_evl_sel = a_evl(pt_flt);
pt_sel = sort(cell2mat(pt(pt_flt)'), 2);
%%
if a_evl_sel(1) == 0
    poly_half1 = [a_evl_sel(:), pt_sel(:,1); flipud(a_evl_sel(:)), flipud(pt_sel(:,2))];
    poly_half2 = [-a_evl_sel(:), pt_sel(:,2); flipud(-a_evl_sel(:)), flipud(pt_sel(:,1))];
    poly1 = {[poly_half1;poly_half2]};
else
    poly1 = [a_evl_sel(:), pt_sel(:,1); flipud(a_evl_sel(:)), flipud(pt_sel(:,2))];
    poly2 = [-a_evl_sel(:), pt_sel(:,2); flipud(-a_evl_sel(:)), flipud(pt_sel(:,1))];
    poly1 = {poly1, poly2};
end
poly2 = cellfun(@(p) [p(:,1), -p(:,2)], poly1, 'uniformoutput', false);
poly_ab = [poly1 poly2];
poly = cellfun(@(p) bsxfun(@plus, S1(:)', p(:,1)*v12' + p(:,2)*v12t'), poly_ab, 'uniformoutput', false)

cla
drawPolygon(poly);

%%

% assumeAlso(dm>0);
% assumeAlso(a>0 and a<dm);
% assumeAlso(b>0 and b<dm);
% assumeAlso(d12>0);
% assumeAlso(sqrt(d12)>0);

