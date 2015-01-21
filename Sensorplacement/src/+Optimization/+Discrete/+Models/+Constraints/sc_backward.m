function sc_backward( discretization, config )
%ADD_COMBINATIONS Summary of this function goes here
%   Detailed explanation goes here


%% write constraints
%%% first part of and constrints
% -si2 + di1i2 <= 0
% two values per row and two equations
%  si_dij_lhs >= [si_dij_i, si_dij_j(l,r)]   <= si_dij_rhs
%                 Si1 ... Si2 .... di1i2
%  -inf       <= [ 1               -1   ] >= 0
%  -inf       <= [        1        -1   ] >= 0

% fid = pc.model.(model_type).st.fid;
fid = config.filehandles.st;
%%
loop_display(discretization.num_comb, 10);
write_log(' writing constraints...');
for idc = 1:discretization.num_comb
    %%
    sc_row = discretization.sc(idc,:);
    fprintf(fid,'IFs%1$ds%2$dTHENs%1$d: s%1$d -s%1$ds%2$d >= 0\n',  sc_row(1), sc_row(2), idc);
    fprintf(fid,'IFs%1$ds%2$dTHENs%2$d: s%2$d -s%1$ds%2$d >= 0\n',  sc_row(1), sc_row(2), idc);
    if mod(idc,discretization.num_comb/1000)<1
        loop_display(idc);
    end
end
% write_log('...done ');


%%
% pc = model.finish(pc,model_type);
% write_log('...done ');
return;

%% Tests
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality); 

config = Configurations.Optimization.Discrete.mspqm;
%%
Optimization.Discrete.Models.Constraints.sc_backward(discretization, config);



