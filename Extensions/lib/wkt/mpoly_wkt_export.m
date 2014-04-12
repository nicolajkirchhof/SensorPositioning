function mpoly_wkt_export(mpoly, fid)

%fid = fopen(filename, 'w');
%%
fprintf(fid, 'MULTIPOLYGON(');
for idp = 1:numel(mpoly)
    fprintf(fid, '(');
    for idr = 1:numel(mpoly)
        fprintf(fid, '(');
        fprintf(fid, '%f %f,', mpoly{idp}{idr}(:,1:end-1));
        fprintf(fid, '%f %f', mpoly{idp}{idr}(:,end));
        fprintf(fid, ')');
    end
    fprintf(fid, ')');
end
fprintf(fid, ')\n');