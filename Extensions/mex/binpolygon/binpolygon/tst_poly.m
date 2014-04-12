%% tst
% run ..\..\..\..\..\..\startup.m
%%
scale = 100;
p1(1).x = [180, 260, 260, 180 ]'/2;
p1(1).y = [200, 200, 150, 150 ]'/2;
p1(1).hole = 0;
p1(2).x = fliplr([200, 230, 230, 200 ])'/2;
p1(2).y = fliplr([180, 180, 170, 170 ])'/2;
p1(2).hole = 1;

p2.x = [190, 240, 240, 190 ]'/2;
p2.y = [210, 210, 130, 130 ]'/2;
p2.hole = 0;
cla; hold on;
for idp = 1:numel(p1)
    drawPolygon(p1(idp).x, p1(idp).y);
end
drawPolygon(p2.x, p2.y, 'g');
%pout = polygon_clip(convert_poly_simple2contour({p1}), convert_poly_simple2contour({p2}));
%%
colors = hsv(4);
pres = cell(1,4);
for type = 0:3
    %%
    pr = clipper(p1, p2, type, scale);
    pc = polygon_clip(p1, p2, type);
    %     figure; hold on;
    %     for idp = 1:numel(pr)
    %         drawPolygon(pr(idp).x, pr(idp).y, 'color', colors(type,:));
    %     end
    %     for idp = 1:numel(pc)
    %         drawPolygon(pc(idp).x, pc(idp).y, 'color', colors(type,:));
    %     end
    if numel(pr) ~= numel(pc)
%         dbstop;
        error('investigate');
    end
    %%
    ptest.x1 =[];
    ptest.x2 =[];
    ptest.y1 =[];
    ptest.y2 =[];
    ptest.hole = [];
    for idp = 1:numel(pc)
        ptest.x1 = sort([ptest.x1; pr(idp).x], 1);
        ptest.x2 = sort([ptest.x2; pc(idp).x], 1);
        ptest.y1 = sort([ptest.y1; pr(idp).y], 1);
        ptest.y2 = sort([ptest.y2; pc(idp).y], 1);
        ptest.hole = sort([ptest.hole; [pr(idp).hole, pc(idp).hole]], 1);
    end
    %%
    ptest.x = [ptest.x1, ptest.x2];
    ptest.y = [ptest.y1, ptest.y2];
    ptest.result = any(sum(abs(sum(diff(ptest.x,1,2)+diff(ptest.y,1,2), 2)))+sum(diff(ptest.hole,1,2)));
        if ptest.result
%             dbstop;
            error('investigate');
        end
    pres{type+1} = pr;
    
end


% pclip = NET.addAssembly('C:\users\nico\downloads\clipper_ver4.8.8\C#\MatlabPolygonWrapper\bin\x64\Release\ClipperMatlab.dll');
