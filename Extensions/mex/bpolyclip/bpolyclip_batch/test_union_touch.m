%test_union_touch
run c:\Users\nico\workspace\tools.common\lib\matlab\matgeom.m
run c:\Users\nico\workspace\tools.common\lib\matlab\matGeomBoost.m
%%
load test_union_touch
tst_unt = bpolyclip(p1, p2, 3);

cla, hold on;
mb.drawPolygon(tst_unt);
mb.numberPolygon(tst_unt);

%%
tst_unt = bpolyclip(p1, p2, 3, true, 0, 1);

%%
load test_union_touch
tst_unt = bpolyclip_batch({p1, p2}, 3,{1:2}, true, 0, false, 1);
