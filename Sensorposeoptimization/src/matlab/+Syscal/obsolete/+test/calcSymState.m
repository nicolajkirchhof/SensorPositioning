%%
syms sx sy phi px py aoa
F = tan(phi + aoa) - (py - sy)/(px - sx);

fphi = diff(F, phi)
fsy = diff(F, sy)
fsx = diff(F, sx)
fpx = diff(F, px)
fpy = diff(F, py)