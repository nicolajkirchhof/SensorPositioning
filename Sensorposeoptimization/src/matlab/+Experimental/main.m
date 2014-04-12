function data = main

struct data1 data2;
data1.x = 1;
data2.x = 2;
funList = {@fun1,@fun2};
dataList = {data1,data2}; % or pass file names 
% resultList = cell(1,2);

matlabpool open 2
spmd
    labBarrier
	resultList = funList{labindex}(dataList{labindex});
end
matlabpool close

function y = fun1(data1)
time1=clock;
fprintf('%02d : %02d : %02f\n',time1(4),time1(5),time1(6))
labindex
pause(5)
y = 4;
disp('run f1');

function y = fun2(data2)
time2=clock;
fprintf('%02d : %02d : %02f\n',time2(4),time2(5),time2(6))
labindex
pause(5);
y = 20;
disp('run f2')