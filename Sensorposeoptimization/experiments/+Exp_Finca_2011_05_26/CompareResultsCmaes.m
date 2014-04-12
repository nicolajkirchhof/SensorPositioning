states = [];
input = [];
for idx_run = 1:100
    [result] = Exp_Labor_2011_05_10.runCmaes('DoubleSensorMeasuresRoomBoundedCMAES', true);
    input(:, end+1) = result.opt_description.x0;
    states(:, end+1) = result.state;
    close all; clear result;
end

