multipoly{1}{1} = int64([100 200 200 100 100; 100 100 200 200 100]);
multipoly{2}{1} = int64([100 200 200 100 100; 100 100 200 200 100] + 200);

run c:\users\nico\workspace\tools.common\lib\matlab\matgeom.m

%%
cla
hold on;
drawPolygon(multipoly{2}{1}');
drawPolygon(multipoly{1}{1}');
%%
[px, py] = meshgrid(100:3:400, 100:3:400);
pts = int64([px(:) py(:)]');
drawPoint(pts', '.g');
%%

[in on] = binpolygon(pts, multipoly);
drawPoint(pts(:, in)', '.r');