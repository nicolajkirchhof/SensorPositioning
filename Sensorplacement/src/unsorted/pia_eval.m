%% pia eval

addpath('tmp');
fnames = dir('tmp\P1*_qclip.lp');
%%
    for idx = 1:numel(fnames);
         fmodel = ['tmp\' fnames(idx).name];
        [~, fmodelbase] = fileparts(fmodel);
        fprintf(1, '---- solving %s ----', fmodel)
        solver.cplex.startext(fmodel);
    end
    
    %%
    %two coverage
    fmodel = 'tmp\P1-01-EtPart-supd700-wgpd700-suad30_coverage_sameplace.lp';
            [~, fmodelbase] = fileparts(fmodel);
        fprintf(1, '---- solving %s ----', fmodel)
        solver.cplex.startext(fmodel);
    