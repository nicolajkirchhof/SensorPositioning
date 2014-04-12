function sol = startext(filename)

% filename is xy\xy\yie.lp
% path = fileparts(filename);
solfile = [filename(1:end-2) 'sol'];
logfile = [filename(1:end-2) 'cplog'];
if exist(solfile, 'file')
    delete(solfile);
end
if exist(logfile, 'file')
    delete(logfile);
end

cpx_read = sprintf('"read %s"', filename);
cpx_log = sprintf('"set logfile %s"', logfile);
% cpx_workdir = sprintf('"set workdir %s"', workdir);
cpx_start = '"optimize"';
cpx_write = sprintf('"write %s"', solfile);

cmd = sprintf('cplex.exe -c %s %s %s %s "quit"', cpx_read, cpx_log, cpx_start, cpx_write);
%%%
% cmd = sprintf('CplexMIPOpt.exe --workdir d:%stmp --input-file %s --threads 3 --workmem 1000 --node-file 3 --tree-limit 3e3', filesep, filename);
system(cmd, '-echo');
fprintf(1, '\n');
%
if nargout > 0
if ~exist(solfile, 'file')
    sol = [];
    return;    
end
sol = solver.cplex.read_solution_it(solfile);
else
    write_log('solution %s was written');
end
