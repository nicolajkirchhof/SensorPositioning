%% Replace texts

h = findobj(gca, 'String', 'cmqm_nonlin_it');
set(h, 'String', sprintf('CMQM\n(FMIN)'), 'VerticalAlignment', 'middle');

h = findobj(gca, 'String', 'cmqm_cmaes_it');
set(h, 'String', sprintf('CMQM\n(CMAES)'), 'VerticalAlignment', 'middle')

h = findobj(gca, 'String', 'gco');
set(h, 'String', sprintf('GCO'))

h = findobj(gca, 'String', 'gcss');
set(h, 'String', sprintf('GCSS'))

h = findobj(gca, 'String', 'gsss');
set(h, 'String', sprintf('GSSS'))

h = findobj(gca, 'String', 'stcm');
set(h, 'String', sprintf('STCM'))

h = findobj(gca, 'String', 'mspqm');
set(h, 'String', sprintf('MSPQM'))

h = findobj(gca, 'String', 'bspqm');
if ~isempty(h)
set(h, 'String', sprintf('BSPQM'))
end

h = findobj(gca, 'String', 'bspqm_rpd');
if ~isempty(h)
set(h, 'String', sprintf('RPD\nBSPQM'), 'VerticalAlignment', 'middle')
end

h = findobj(gca, 'String', 'mspqm_rpd');
if ~isempty(h)
set(h, 'String', sprintf('RPD\nMSPQM'), 'VerticalAlignment', 'middle')
end