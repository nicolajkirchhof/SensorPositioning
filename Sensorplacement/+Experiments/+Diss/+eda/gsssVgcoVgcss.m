%%
cr_num_initials = cellfun(@(x) numel(x.ssc.sensors_selected), all_eval.conference_room.gsss);
sf_num_initials = cellfun(@(x) numel(x.ssc.sensors_selected), all_eval.small_flat.gsss);
lf_num_initials = cellfun(@(x) numel(x.ssc.sensors_selected), all_eval.large_flat.gsss);
of_num_initials = cellfun(@(x) numel(x.ssc.sensors_selected), all_eval.office_floor.gsss);
%%
clf
hold on 
plot(cr_num_initials(:), 'color', 0.8*ones(1,3))
plot(sf_num_initials(:), 'color', 0.6*ones(1,3))
plot(lf_num_initials(:), 'color', 0.4*ones(1,3))
plot(of_num_initials(:), 'color', 0.2*ones(1,3))
xlim([0 2500])
ylabel('$\#SP$')
legend({'CR', 'SF', 'LF', 'OF'}, 'Location', 'EastOutside')


    filename = sprintf('SscSelectedSensors.tex');
    full_filename = sprintf('export/%s', filename);
    matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '2cm',...
        'width', '10cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    Figures.compilePdflatex(filename, true, false);
    
%%
cr_num_finals = cellfun(@(x) x.all_sp, all_eval.conference_room.gsss);
sf_num_finals = cellfun(@(x) x.all_sp, all_eval.small_flat.gsss);
lf_num_finals = cellfun(@(x) x.all_sp, all_eval.large_flat.gsss);
of_num_finals = cellfun(@(x) x.all_sp, all_eval.office_floor.gsss);  
%%
clf
hold on 
plot(cr_num_finals(:), 'color', 0.8*ones(1,3))
plot(sf_num_finals(:), 'color', 0.6*ones(1,3))
plot(lf_num_finals(:), 'color', 0.4*ones(1,3))
plot(of_num_finals(:), 'color', 0.2*ones(1,3))
xlim([0 2500])
ylabel('$\#SP$', 'Interpreter', 'none')
legend({'CR', 'SF', 'LF', 'OF'}, 'Location', 'EastOutside')

%%
cr_ratio = cr_num_finals./cr_num_initials;
sf_ratio = sf_num_finals./sf_num_initials;
lf_ratio = lf_num_finals./lf_num_initials;
of_ratio = of_num_finals./of_num_initials;

fprintf('means cr=%g, sf=%g, lf=%g, of=%g\n', mean(cr_ratio(:)), mean(sf_ratio(:)), ...
    mean(lf_ratio(:)), mean(of_ratio(:)))

%%
clf
hold on 
plot(cr_ratio(:), 'color', 0.8*ones(1,3))
plot(sf_ratio(:), 'color', 0.6*ones(1,3))
plot(lf_ratio(:), 'color', 0.4*ones(1,3))
plot(of_ratio(:), 'color', 0.2*ones(1,3))
xlim([0 2500])
ylabel('$\#SP$', 'Interpreter', 'none')
legend({'CR', 'SF', 'LF', 'OF'}, 'Location', 'EastOutside')