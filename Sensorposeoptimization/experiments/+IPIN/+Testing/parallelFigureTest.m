function parallelFigureTest
import Experimental.IPIN.Testing.*
input.idx_cal = 1;
input.idx_sdr = 2;
input.idx_cw = 3;
% input.config = config;
% input.init_length = init_length;
% input.debug = @(x) disp(x);
input.debug = @(x) x;
input.info = @(x) disp(x);
input.gca = gca;

input.protocol.command.stop = 0;
input.protocol.command.start = 1;
input.protocol.action.lab_control = 0;
input.protocol.action.data_polling = 1;
input.protocol.action.data_transmission = 2;

funList = {@fun1};%,@fun2, @fun3};
% funList = {@sensorDataReceiver, @sdrTest};
% dataList = {input_rec, input_cc}; % or pass file names
%%
isOpen = matlabpool('size') > 0;
if isOpen,matlabpool close, end
matlabpool open 1
%
spmd
    funList{labindex}(input);%(dataList{labindex});
end

%%      
matlabpool close
%%

function fun2(input)
labBarrier;
pause(2);
plot(gca, 1, 2, 'o');
end

function fun3(input)
labBarrier;
pause(3);
plot(gca, 1, 3, 'o');
drawnow expose;
end

end