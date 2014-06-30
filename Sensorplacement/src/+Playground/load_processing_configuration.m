function pc = load_processing_configuration(filename)
% generates empty configuration and overwrites all values that are changed
% in the file
pc = processing_configuration;
%%
if exist(filename, 'file')
    content = loadjson(filename);
else
    error('file %s does not exist', pc.environment.file);
%     fprintf(1, 'file %s does not exist', pc.environment.file);
%     return;
end
if isfield(content, 'pc')
    content = content.pc;
else
    content = content.wc;
end
    fn = fieldnames(content);

    for idf = 1:numel(fn)
        pc.(fn{idf}) = content.(fn{idf});
    end


% if ~isempty(pc.poly)
% pc.polycontour = convert_poly_simple2contour(pc); % must be closed!!! x(1) == x(end)
% % pc.polymatlab = convert_poly_simple2matlab(pc); % matlab structure to use with delauny, edges and verticies
% end
