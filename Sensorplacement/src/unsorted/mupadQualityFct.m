% mupad sym evaluation 
%%
clear all;

syms x y s1 s2 x1 x2 y1 y2 dmax d1sq d2sq d12sq phi 

%%
s1 = [x1;y1];
s2 = [x2;y2];

d1sq = sum((s1-[x;y]).^2);
d2sq = sum((s2-[x;y]).^2);
d12sq = sum((s1-s2).^2);

phi = acos((d1sq+d2sq-d12sq)./(2*sqrt(d1sq.*d2sq)));
