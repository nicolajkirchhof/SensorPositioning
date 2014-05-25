clear all;
%
% define Sensor positions
s1 = [-10 0]; s2 = [10 0]; s3 = [0 10];
S = {s1, s2, s3};
% define uncertainty
uc = 0.1;

%% find best target position
x = 0;
y = 0:0.1:9;
sall = zeros(1, numel(y));
fitness = zeros(1, numel(y));
angles = zeros(numel(y), 3);
for i = 1:numel(y)
        t = [x, y(i)];
        fitness(i) = side_evaluations.opt_position_3sensor_trilateration.fitness_opt3SensTrilat(t, S, uc);
        angles(i, :) = angle3Points([s1; s2; s3], [t; t; t], [s2; s3; s1])';
        disp(fitness(i));
end
return

%%
% define target
%tall = [zeros(1,500); 1:500]';
t = [0 0];
%
    % calculate uncertainty polygon
    [s1_incirc, s1_outcirc] = calc_uncertaintyCircles(uc, t, s1);
    [s2_incirc, s2_outcirc] = calc_uncertaintyCircles(uc, t, s2);
    %
    s1_incirc_poly = circleToPolygon(s1_incirc, 500);
    s1_outcirc_poly = circleToPolygon(s1_outcirc, 500);
    s2_incirc_poly = circleToPolygon(s2_incirc, 500);
    s2_outcirc_poly = circleToPolygon(s2_outcirc, 500);
    
    %%%
    % calculate difference polygon with polygon clip diff
    s1_incirc_polystr = create_PolygonStruct(s1_incirc_poly);
    s1_outcirc_polystr = create_PolygonStruct(s1_outcirc_poly);
    s1_diff_polystr = PolygonClip( s1_outcirc_polystr , s1_incirc_polystr , 0 );
    plot_polygon(s1_diff_polystr, 'g');
    hold on;
    s2_incirc_polystr = create_PolygonStruct(s2_incirc_poly);
    s2_outcirc_polystr = create_PolygonStruct(s2_outcirc_poly);
    s2_diff_polystr = PolygonClip( s2_outcirc_polystr , s2_incirc_polystr , 0 );
    plot_polygon(s2_diff_polystr, 'r');
    hold on;
    %%%
    % calculate intersections in the same way
    p_error = PolygonClip(s1_diff_polystr, s2_diff_polystr, 1);



    
    
%% find best sensor position
sall = zeros(200*200, 2);
fitness = zeros(200*200, 2);
cnt = 1;
for x = 1:0.1:20
    for y = 1:0.1:20
        s3all(cnt, :) = [x y];
        fitness(cnt) = fitness_opt3SensTrilat([x y], p_error, uc, t);
        cnt = cnt + 1;
    end
end
return

%%
xall = 1:0.1:20;
yall = 1:0.1:20;
fitnessall = zeros(numel(xall), numel(yall));
cnt = 1;
for i = 1:numel(xall)
    for j = 1:numel(yall)
        fitnessall(i, j) = fitness(cnt);
        cnt = cnt + 1;
    end
end

%%
% optimization options
options.Display = 'iter';
options.MaxFunEvals = 10000;
options.MaxIter = options.MaxFunEvals;
options.PlotFcns = {@optimplotfval,@optimplotx};
options.TolFun = 1e-6;
options.TolX = options.TolFun;
% options.algorithm = 'trust-region-reflective';
% options.Algorithm = 'levenberg-marquardt';

% define problem
optfcn = @(x) fitness_opt3SensTrilat(x, {s1, s2}, uc, t);
problem.objective = optfcn;
% problem.x0 = randi(20, 1, 2);
problem.x0 = [10 10];
% problem.solver = 'fminsearch';
% problem.solver = 'lsqnonlin';
problem.solver = 'fmincon';
problem.options = options;
problem.lb = [0 0];
problem.ub = [20 20];

% [x,fval,exitflag,output] = fminsearch(problem);
% [x,fval,exitflag,output] = lsqnonlin(problem);
[x,fval,exitflag,output] = fmincon(problem);
%%
% define target positions

tall = [0, 5];



% for idt = 1:500
%     t = tall(idt, :);
%     % calculate uncertainty polygon
%     [s1_incirc, s1_outcirc] = calc_uncertaintyCircles(uc, t, s1);
%     [s2_incirc, s2_outcirc] = calc_uncertaintyCircles(uc, t, s2);
%     %
%     s1_incirc_poly = circleToPolygon(s1_incirc, 500);
%     s1_outcirc_poly = circleToPolygon(s1_outcirc, 500);
%     s2_incirc_poly = circleToPolygon(s2_incirc, 500);
%     s2_outcirc_poly = circleToPolygon(s2_outcirc, 500);
%     
%     %%%
%     % calculate difference polygon with polygon clip diff
%     s1_incirc_polystr = create_PolygonStruct(s1_incirc_poly);
%     s1_outcirc_polystr = create_PolygonStruct(s1_outcirc_poly);
%     s1_diff_polystr = PolygonClip( s1_outcirc_polystr , s1_incirc_polystr , 0 );
%     plot_polygon(s1_diff_polystr, 'g');
%     hold on;
%     s2_incirc_polystr = create_PolygonStruct(s2_incirc_poly);
%     s2_outcirc_polystr = create_PolygonStruct(s2_outcirc_poly);
%     s2_diff_polystr = PolygonClip( s2_outcirc_polystr , s2_incirc_polystr , 0 );
%     plot_polygon(s2_diff_polystr, 'r');
%     hold on;
%     %%%
%     % calculate intersections in the same way
%     p_error = PolygonClip(s1_diff_polystr, s2_diff_polystr, 1);
%     plot_polygon(p_error, 'b')
%     for idx = 1:numel(p_error)
%         p_area(idx) = polyarea(p_error(idx).x, p_error(idx).y);
%     end
%     % PolygonClip( P1, P2, 1 ) % 1 = intersection
% end