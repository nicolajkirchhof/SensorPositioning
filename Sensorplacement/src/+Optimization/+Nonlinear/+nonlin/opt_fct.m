function x = opt_fct(poses)
        pc.problem.S = reshape(poses, 3, []);
        pc.progress.sensorspace.visibility = false;
        pc.progress.sensorspace.sensorcomb = false;
        pc = sensorspace.visibility(pc);
        pc = quality.wss.dop_ang(pc);
        x = cellfun(@sum, pcopt.quality.wss_dop_ang.val);
%%
        


    end