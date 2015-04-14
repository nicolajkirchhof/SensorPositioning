hao =@(x,y) x/ceil(sqrt(2*y+1/4)+1/2);
hoa =@(x,y) 2*y/x;
%%

eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
opt_names = {'gco_i', 'gcss', 'gsss'};
close all;

for ideval = 1:numel(eval_names)
    %%
    %     ideval = 1;
    eval_name = eval_names{ideval};
flt_mspqm = ~cellfun(@isempty, all_eval.(eval_name).mspqm);

haos = cellfun(@(x) hao(numel(x.sensors_selected),numel(x.sc_selected)), all_eval.(eval_name).gco(flt_mspqm));
% hoas = cellfun(@(x) hoa(numel(x.sensors_selected),numel(x.sc_selected)), all_eval.(eval_name).mspqm(flt_mspqm));
hreal = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.(eval_name).gco(flt_mspqm), all_eval.(eval_name).mspqm(flt_mspqm));
hgco = cellfun(@(x) numel(x.sensors_selected), all_eval.(eval_name).gco(flt_mspqm));
hgcosc = cellfun(@(x) numel(x.sc_selected), all_eval.(eval_name).gco(flt_mspqm));
hmspqm = cellfun(@(x) numel(x.sensors_selected), all_eval.(eval_name).mspqm(flt_mspqm));
% hgsss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.conference_room.gsss(flt_mspqm), all_eval.conference_room.mspqm(flt_mspqm));
% hgcss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.conference_room.gcss(flt_mspqm), all_eval.conference_room.mspqm(flt_mspqm));


% plot([haos, hoas, hreal])
% legend('haos', 'hoas', 'hreal');
% cbar = linspace(0,0.6,3);
h = plot([haos,  hreal, hgco, hgcosc, hmspqm], 'k');
set(h(2), 'color', 0.6*ones(1,3));
% set(h(2), 'linestyle', '-')
set(h(2), 'linestyle', ':')
set(h(4), 'linestyle', ':', 'color', 0.8*ones(1,3));
% set(h(4), 'linestyle', ':')
% legend('haos', 'hoa', 'hgsss', 'hgcss');

    %%
    filename = sprintf('WCAR%s.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
    matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '2cm',...
        'width', '10cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
%     find_and_replace(full_filename, 'ylabel={\[\\#\]}', 'ylabel={[\\#SP]},\nevery axis y label/.style={at={(current axis.north west)},anchor=east}');
%     find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
%     find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
%     find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', '');
%     find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=1pt');
    Figures.compilePdflatex(filename, false, false);
end
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