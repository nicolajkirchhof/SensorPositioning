hao =@(x,y) x/(sqrt(2*y+1/4)+1/2);
hoa =@(x,y) 2*y/x;
%%
flt_mspqm = ~cellfun(@isempty, all_eval.conference_room.mspqm);

haos = cellfun(@(x) hao(numel(x.sensors_selected),numel(x.sc_selected)), all_eval.conference_room.gco(flt_mspqm));
hoas = cellfun(@(x) hoa(numel(x.sensors_selected),numel(x.sc_selected)), all_eval.conference_room.mspqm(flt_mspqm));
hreal = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.conference_room.gco(flt_mspqm), all_eval.conference_room.mspqm(flt_mspqm));
hgsss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.conference_room.gsss(flt_mspqm), all_eval.conference_room.mspqm(flt_mspqm));
hgcss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.conference_room.gcss(flt_mspqm), all_eval.conference_room.mspqm(flt_mspqm));

cla
% plot([haos, hoas, hreal])
% legend('haos', 'hoas', 'hreal');
cbar = linspace(0,0.6,4);
h = plot([haos,  hreal, hgsss, hgcss], 'k')
set(h(3:4), 'color', 0.6*ones(1,3));
set(h(2), 'linestyle', '-')
set(h(3), 'linestyle', '--')
set(h(4), 'linestyle', ':')
% legend('haos', 'hreal', 'hgsss', 'hgcss');


%%
flt_mspqm = ~cellfun(@isempty, all_eval.small_flat.mspqm);

haos = cellfun(@(x) hao(numel(x.sensors_selected),numel(x.sc_selected)), all_eval.small_flat.gco(flt_mspqm));
hoas = cellfun(@(x) hoa(numel(x.sensors_selected),numel(x.sc_selected)), all_eval.small_flat.mspqm(flt_mspqm));
hreal = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.small_flat.gco(flt_mspqm), all_eval.small_flat.mspqm(flt_mspqm));
hgsss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.small_flat.gsss(flt_mspqm), all_eval.small_flat.mspqm(flt_mspqm));
hgcss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.small_flat.gcss(flt_mspqm), all_eval.small_flat.mspqm(flt_mspqm));
figure

% plot([haos, hoas, hreal])
% legend('haos', 'hoas', 'hreal');
cbar = linspace(0,0.6,4);
h = plot([haos,  hreal, hgsss, hgcss], 'k')
set(h(3:4), 'color', 0.6*ones(1,3));
set(h(2), 'linestyle', '-')
set(h(3), 'linestyle', '--')
set(h(4), 'linestyle', ':')
% legend('haos', 'hreal', 'hgsss', 'hgcss');

%%
flt_mspqm = ~cellfun(@isempty, all_eval.large_flat.mspqm);

haos = cellfun(@(x) hao(numel(x.sensors_selected),numel(x.sc_selected)), all_eval.large_flat.gco(flt_mspqm));
hoas = cellfun(@(x) hoa(numel(x.sensors_selected),numel(x.sc_selected)), all_eval.large_flat.mspqm(flt_mspqm));
hreal = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.large_flat.gco(flt_mspqm), all_eval.large_flat.mspqm(flt_mspqm));
hgsss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.large_flat.gsss(flt_mspqm), all_eval.large_flat.mspqm(flt_mspqm));
hgcss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.large_flat.gcss(flt_mspqm), all_eval.large_flat.mspqm(flt_mspqm));
figure

% plot([haos, hoas, hreal])
% legend('haos', 'hoas', 'hreal');
cbar = linspace(0,0.6,4);
h = plot([haos,  hreal, hgsss, hgcss], 'k')
set(h(3:4), 'color', 0.6*ones(1,3));
set(h(2), 'linestyle', '-')
set(h(3), 'linestyle', '--')
set(h(4), 'linestyle', ':')
% legend('haos', 'hreal', 'hgsss', 'hgcss');


%%
m = all_eval.office_floor.mspqm;
mfull = cell(51,51);
mfull(1:21, 1:21) = m;
all_eval.office_floor.mspqm = mfull;