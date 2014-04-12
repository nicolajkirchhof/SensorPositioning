%%
%scal = syscal.eval.createRunParameters(1, [0 0], [0.15 0.15 7*pi/180]);


for cnt=1:2  
    for i = 1:10
        for j = 1:3
            
            malg = {'trust-region-reflective' , {'levenberg-marquardt', 0.01'}};
            mstd = [[0:0.2:2]',[0:0.2:2]'];
            msens = [[0:0.1:1]',[0:0.1:1]',[0:1:10]'*pi/180];
            
            scal = syscal.createRunParameters('tcraw1', 'rnd', mstd(i,:), msens(i,:));
            %scal = syscal.eval.createRunParameters('tcqw1', 'rnd', {'room', ''}, [0.5 0.5 20*pi/180]);
            %scal = syscal.createRunParameters('tcraw1', 'rnd', {'room', ''}, [0.5 0.5 20*pi/180]);
            scal.userData.plotState = true;
            
            fun = @(x) syscal.calcStateRaw(x, scal);
            
            opt = optimset('display', 'iter'...
                , 'maxfunevals', 500*numel(scal.stateCurrent) ...
                , 'maxiter', 500*numel(scal.stateCurrent) ...
                , 'plotfcns', @optimplotfval...
                , 'tolfun', 1e-6...
                , 'tolx', 1e-6...
                ...    , 'Jacobian', 'on'...
                , 'Algorithm', malg{cnt}...
                ..., 'Algorithm', 'trust-region-dogleg'...%DEFAULT
                ...    , 'Algorithm', 'trust-region-reflective'...
                ...    , 'Algorithm', {'levenberg-marquardt', 0.01'}...
                ...    , 'DiffMaxChange', 1 ...
                ...    , 'DiffMinChange', 1e-3 ...
                );
            
            P.objective = fun;
            P.x0 = scal.stateCurrent;
            P.options = opt;
            P.solver = 'fsolve';
            
            
            [state, fval, exitflag, output ] = fsolve(P);
            save(['res/mat/ev' num2str(cnt) num2str(i) num2str(j)]);
            close all; clear scal;
        end
    end
end