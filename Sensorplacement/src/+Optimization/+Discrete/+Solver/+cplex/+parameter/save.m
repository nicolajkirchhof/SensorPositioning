function save( c )
%SAVE Summary of this function goes here
%   Detailed explanation goes here
%%
c.writeParam('_cplex.par');
logfile = [pwd filesep 'params.log'];
c_log = sprintf('"set logfile %s"', logfile);
c_read = '"read _cplex.par par"';
c_write = '"display settings changed"';

system(sprintf('cplex -c %s %s %s', c_log, c_read, c_write));

%% write parameter file
fid = fopen(logfile);
fido = fopen('cplex.par', 'W');
lne = fgetl(fid);
start_output = false;
while ischar(lne)
    if ~isempty(strfind(lne, logfile))
        start_output = true;
        lne = fgetl(fid);
    end
    if start_output
        fprintf(fido, '%s\n', lne);
        fprintf(1, '%s\n', lne);
    end
    lne = fgetl(fid);
end
fclose(fid);
fclose(fido);
