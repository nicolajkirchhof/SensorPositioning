function c = default(  )
%INIT Summary of this function goes here
%   Detailed explanation goes here
%--threads 3 --workmem 1000 --node-file 3 --tree-limit 3e3', filesep, filename);
%%
c = Cplex('parset');
c.Param.workmem.Cur = 1000;
c.Param.workdir.Cur = 'd:\tmp';
c.Param.threads.Cur = 3;
c.Param.mip.strategy.file.Cur = 3;
c.Param.timelimit.Cur = 600; % 10 min
c.Param.mip.limits.treememory.Cur = 5e3; % 5 GB

end

