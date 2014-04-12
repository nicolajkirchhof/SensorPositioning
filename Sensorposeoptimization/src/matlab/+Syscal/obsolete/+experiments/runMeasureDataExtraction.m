files = dir('*.mat');

for fidx = 1:numel(files)
    load(files(fidx).name, 'tsc_abx', 'tsc_ref');
        
    fn = tsc_abx.fieldnames;
        
    for fnidx = 5:numel(fn)
        %%
        syscal.measureExtractConstPositions(tsc_abx.(fn{fnidx}).Data, tsc_ref.ref_0.Data)
    