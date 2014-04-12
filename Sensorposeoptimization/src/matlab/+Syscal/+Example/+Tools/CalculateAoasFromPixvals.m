function aoas = calculateAoasFromPixvals(syscal_config)

options = optimset;
% Modify options setting
options = optimset(options,'Display', 'off');
options = optimset(options,'DiffMinChange', 0.01 );
options = optimset(options,'GradObj', 'off');
options = optimset(options,'Hessian', 'off');
options = optimset(options,'TolFun', 0.0001);
options = optimset(options,'TolX', 0.0001);
self.opt_ = options;

pixval = syscal_config.pixval;
aoas = {};
filter = ThILo.Detail.PreProcessor.AoaExtractor;
for idx_sensor = 1:size(pixval, 1)
    for idx_measure = 1:size(pixval, 2)
        if isempty(pixval{idx_sensor, idx_measure})
            aoas{idx_sensor, idx_measure} = nan;
        else
            position = [];
            for i = 1:size(pixval{idx_sensor, idx_measure}, 2)
                sobj = syscal_config.sensor_objects{idx_sensor};
                %fun = @(x) sobj.likelihood(pixval{idx_sensor, idx_measure}(:,i),x);
                %position(:,i) = fminsearch(fun, [3;3]);
                %pdiff = sobj.Position(1:2) - position(:,i);
                %aoa(i) = atan2(pdiff(1,1), pdiff(2,1));
                filter.Sensor = sobj;
                [aoa(:,i)] = filter.apply(pixval{idx_sensor, idx_measure}(:,i));
                cla, plot(sobj.Position(1,1), sobj.Position(2,1), 'ro');
                hold on;
                plot(syscal_config.measure_pose.reference(idx_measure, 1), syscal_config.measure_pose.reference(idx_measure, 2), 'bx');
                % draw line from x=0 to x=7
                position(1,1) = 0;
                position(2,1) = tan(aoa(1, i)+sobj.Orientation(3,1)) * (-sobj.Position(1,1)) + sobj.Position(2,1);
                position(1,2) = 1;
                position(2,2) = tan(aoa(1, i)+sobj.Orientation(3,1)) * (position(1,2)-sobj.Position(1,1)) + sobj.Position(2,1);
                while position(2,2) < 7 && position(1,2) < 7
                    position(1,2) = position(1,2)+1;
                    position(2,2) = tan(aoa(1, i)+sobj.Orientation(3,1)) * (position(1,2) -sobj.Position(1,1)) + sobj.Position(2,1);
                end
                %plot(position(1, i), position(2, i), 'go');
                line([position(1,:)'], [position(2,:)]);
            end
            aoas{idx_sensor, idx_measure} = aoa;
        end
    end
end
end