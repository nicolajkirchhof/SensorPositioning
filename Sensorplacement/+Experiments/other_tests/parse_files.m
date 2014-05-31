%DEBUG = true;
DEBUG = false;
%function parse_files
addpath /home/nico/workspace/tools.common/lib/matlab/custom/jsonlab_0.9.0_nico/
%fid = fopen('clearedfiles.txt');
files = dir('/scratch/cl100/*.json');
log = fopen('matlab_log.txt', 'w');

% tline = {fgetl(fid)};

% while ischar(tline{end})
   % tline{end+1} = fgetl(fid);
%end
%fclose(fid);
%%
jsondir = '/scratch/cl100/';
%matlabpool open 2

for idf = 1:numel(files)
    filepath = [jsondir files(idf).name];
	if exist([filepath '.mat'], 'file') > 0
	fprintf(log, 'skipping %s \n', filepath);
	continue; 
	end
%     eval(['!./bin/p7zip/7z x cl100.7z ' filepath]);
	fprintf(log, 'loading %s\n', filepath);
    if ~DEBUG    
    wc = loadjson(filepath);    
    save(filepath, wc);
    end
end
fclose(log);
exit
%matlabpool close

%function saveme(filepath, wc)
%    save([filepath '.mat'], 'wc');

