function write_log(str, varargin)
persistent fid ident enabled
if isempty(str)
    return;
elseif strcmp(str, '#on')
    str = '#logging is on';
    enabled = true;
elseif strcmp(str, '#off')
    write_log('#logging is off');
    enabled = false;
end
if isempty(enabled)
    ident = [];
    enabled = true;
    if nargin > 0
        if ischar(str)
            %% this part is quite errorprone and should be considererd to be removed
            [~, ~, ext] = fileparts(str);
            if strcmpi(ext, '.log')
                fid = fopen(str, 'w');
            else
                warning('filename does not end on .log, using default output instead');
                fid = 1;
                write_log(str);
            end
        elseif isnumeric(str)
            fid = str;
        else
            warning('cannot assign output using console...');
            fid = 1;
        end
    else
        filename = ['log_', datestr(now, 30) '.log'];
        fid = fopen(filename, 'w');        
    end
    return;
end
if ~enabled
    return;
end

if strcmp(str, '#close')
    if fid > 0
   fclose(fid);
   clear fid;
   return;
    end
elseif strcmp(str(1), ' ')
    str = str(2:end);
    ident = [ident '\t'];
elseif strcmp(str(end), ' ')
    str = ['\t' str(1:end-1)];
    ident = ident(1:end-2);
end

if nargin > 1
    fprintf(fid, [ident str], varargin{:});
else
    fprintf(fid, [ident str]);
end
fprintf(fid, '\n');

return;
%% Testing start
write_log('this is not a file');
write_log('logging...');
clear write_log
write_log('this_is_a_file.log');
write_log('logging...');
write_log('close');
fid = fopen('this_is_a_file.log');
if fid > 0
fscanf(fid, '%s')
fclose(fid);
end
delete 'this_is_a_file.log';
clear write_log
write_log(1);
write_log('logging...');
clear write_log
%% testing ident
clear write_log
write_log('logging...');
write_log(' starting ident');
write_log('log in ident');
write_log(' starting ident');
write_log('log in ident');
write_log('ending ident ');
write_log('log in ident');
write_log('ending ident ');
write_log('log in ident');
%% testing enable
clear write_log
write_log('logging...');
write_log(' starting ident');
write_log('ending ident ');
write_log('#off'); 
write_log('log in offmode');
write_log('log in offmode');
write_log('#on'); 
write_log('log in ident');
write_log('log in ident');






