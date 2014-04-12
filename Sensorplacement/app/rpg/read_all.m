%% read all polygons
files = dir('poly*');
poly_dbl = cell(1, numel(files));
poly_int = cell(1, numel(files));
pct = 0;
for idf = 1:numel(files)
    poly_dbl{idf} = read_poly(files(idf).name)*10000;
    poly_int{idf} = int64(poly_dbl{idf});
    if floor(idf*100/numel(files)) > pct
        pct = idf*100/numel(files);
        disp(pct);
    end
end
