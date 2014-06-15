function cpx = start(filename)
%%
% filename is xy\xy\yie.lp
% path = fileparts(filename);
solfile = [filename(1:end-2) 'sol'];
logfile = [filename(1:end-2) 'log'];
if exist(solfile, 'file')
    delete(solfile);
end
if exist(logfile, 'file')
    delete(logfile);
end

cpx = Cplex();
cpx.readParam('_cplex.par');
cpx.readModel(filename);
cpx.solve();
cpx.writeSolution(solfile);
%%
% copyfile([cpx.Param.workdir.Cur filesep 'cplex.log'], logfile);
