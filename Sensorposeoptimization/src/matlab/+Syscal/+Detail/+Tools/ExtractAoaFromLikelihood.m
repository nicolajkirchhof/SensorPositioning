function [ aoa, position ] = ExtractAoaFromLikelihood( sobj, pixval_normalized, ref, debug )
%EXTRACTAOAFROMLIKELIHOOD Summary of this function goes here
%   Detailed explanation goes here
if nargin < 4
    debug = false;
end

options = optimset;
% Modify options setting
options = optimset(options,'Display', 'off');
%options = optimset(options,'DiffMinChange', 0.01 );
%options = optimset(options,'GradObj', 'off');
%options = optimset(options,'Hessian', 'off');
options = optimset(options,'TolFun', 1e-8);
options = optimset(options,'TolX', 1e-8);

[~, idx_guess] = max(pixval_normalized);
for idx_aoas = 1:numel(idx_guess)
    initial_guess_aoa = sobj.twist(idx_guess(idx_aoas));
    initial_guess_radius = 2;
    
    initial_guess_position(1,1) = sobj.Position(1,1) + initial_guess_radius * cos(initial_guess_aoa+sobj.Orientation(3));
    initial_guess_position(2,1) = sobj.Position(2,1) + initial_guess_radius * sin(initial_guess_aoa+sobj.Orientation(3));
    
    if debug
        cla
        %subplot(2,1,1)
        plot(sobj.Position(1,1), sobj.Position(2,1), 'ro');
        hold on;
        plot(ref(1,1), ref(2, 1), 'bx');
        plot(initial_guess_position(1,1), initial_guess_position(2,1), 'kx');
        axis([-1 6 -1 6]);
    end
    
    fun = @(x) 1-sobj.likelihood(pixval_normalized(:,idx_aoas), x);
    position(:,idx_aoas) = fminsearch(fun, initial_guess_position,options);
    pdiff = position(:,idx_aoas) - sobj.Position(1:2, 1);
    aoa(idx_aoas) = atan2(pdiff(2,1), pdiff(1,1))-sobj.Orientation(3);
    
    if (debug)
        plot(position(1,1), position(2,1), 'go');
    end
end
end

% cnt = 1;
% scale = 0:0.05:5;
% for x = scale
%     for y = scale
%         map(:, cnt) = [x;y];
%         cnt = cnt+1;
%     end
% end
% lh = sobj.likelihood(pixval_normalized, map);
% plh = reshape(lh, numel(scale), []);
% figure,imagesc(flipud(plh));






