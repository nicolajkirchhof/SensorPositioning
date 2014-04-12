%%
run c:\users\nico\workspace\tools.common\lib\matlab\orig\matGeom-1.1.6-full\matGeom\matGeom\setupMatGeom.m

fun_drawPolygon = @(x) drawPolygon(x');

load testcase1.mat

convex_partition = polypartition(testpoly, 3);
%%
cla; hold on; cellfun(fun_drawPolygon, convex_partition);
%%

%%
poly_result = cell(1,4);
for idx = 1:4
    poly_result{idx} = polypartition(testpoly, idx);
end