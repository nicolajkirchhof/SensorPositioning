function plotPixvalAoas(syscal_config, pixval, reference)
 
prep = syscal_config.preprocessors;
filter = ThILo.Detail.PreProcessor.AoaExtractor;

cla
for idx_sensor = 1:8
    for i=1:50, norm_pixval = syscal_config.preprocessors{idx_sensor}.apply(pixval(1,idx_sensor*8-7:idx_sensor*8)'); end
    sobj =syscal_config.sensor_objects{idx_sensor};
    if ~isempty(norm_pixval)
        filter.Sensor = sobj;
        aoa = filter.apply(norm_pixval);
        
        plot(sobj.Position(1,1), sobj.Position(2,1), 'ro');
        hold on;
        plot(reference(1,1), reference(1, 2), 'bx');
        
        for i = 1:2:numel(aoa)
            %draw line from x=0 to x=7
            % fast hack for right angle summation
            position(1,1) = 0;
            position(2,1) = tan(sobj.Orientation(3,1)+aoa(1, i)) * (position(1,1)-sobj.Position(1,1)) + sobj.Position(2,1);
            position(1,2) = 6;
            position(2,2) = tan(sobj.Orientation(3,1)+aoa(1, i)) * (position(1,2)-sobj.Position(1,1)) + sobj.Position(2,1);
            line(position(1,:)', position(2,:));

            %             disp(Mltools.rad2deg(sobj.Orientation(3,1)));
            %             disp(' ');
            %             disp(Mltools.rad2deg(aoa(1, i)));
            %             disp(' ')
            %             disp(Mltools.rad2deg(sobj.Orientation(3,1)-aoa(1, i)));
        end
    end
    %
    %     position(1,1) = 0;
    %     position(2,1) = tan(sobj.Orientation(3,1)) * (0-sobj.Position(1,1)) + sobj.Position(2,1);
    %     position(1,2) = 7;
    %     position(2,2) = tan(sobj.Orientation(3,1)) * (position(1,2)-sobj.Position(1,1)) + sobj.Position(2,1);
    %     line([position(1,:)'], [position(2,:)], 'Color',[.8 .8 .8]);
    %     s_flt = [1,1,0,0,1,1,0,0];
    %     if s_flt(idx_sensor) > 0
    %         position(1,1) = 0;
    %         position(2,1) = tan(sobj.Orientation(3,1)-.1) * (position(1,1)-sobj.Position(1,1)) + sobj.Position(2,1);
    %         position(1,2) = 7;
    %         position(2,2) = tan(sobj.Orientation(3,1)-.1) * (position(1,2)-sobj.Position(1,1)) + sobj.Position(2,1);
    %         line([position(1,:)'], [position(2,:)], 'Color',[0 0 .8]);
    %
    %     else
    %         position(1,1) = 0;
    %         position(2,1) = tan(sobj.Orientation(3,1)+.1) * (position(1,1)-sobj.Position(1,1)) + sobj.Position(2,1);
    %         position(1,2) = 7;
    %         position(2,2) = tan(sobj.Orientation(3,1)+.1) * (position(1,2)-sobj.Position(1,1)) + sobj.Position(2,1);
    %         line([position(1,:)'], [position(2,:)], 'Color',[0 0 .8]);
    %     end
    axis([0.9 7 0 7]);
end
