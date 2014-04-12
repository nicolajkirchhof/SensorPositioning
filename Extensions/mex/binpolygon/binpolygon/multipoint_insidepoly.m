function in = multipoint_insidepoly(points, poly)
[xlim, ylim, plim, qlim] = comp_bb_bp(poly);
num_poly_points = size(poly,2);
%%
in = false(1, size(points,2));


[ply_sorted ply_idx] = sort(poly, 2);
%%
for idp = 1:size(points, 2)
    px = points(1,idp);
    py = points(2,idp);
    pp = px+py;
    qp = px-py;
    
    %% DEBUG FIND FIRST POINT IN POLYGON
%     for idp = 1:size(points, 2); px = points(1,idp); py = points(2,idp); qp = px-py; pp = px+py; if xlim(1)<=px && xlim(2)>=px && ylim(1)<=py && ylim(2)>=py && plim(1)<=pp && plim(2)>= pp && qlim(1)<=qp && qlim(2)>=qp; idp, break; end; end;
    %%
    % test with bounding box
    if xlim(1)<=px && xlim(2)>=px && ylim(1)<=py && ylim(2)>=py && ...
            plim(1)<=pp && plim(2)>= pp && qlim(1)<=qp && qlim(2)>=qp
        %use shortest way out
%         dist = [px-xlim(1) xlim(2)-px py-ylim(1) ylim(2)-py];
        x_dir_int = ply_sorted(1,:)>px;
        y_dir_int = ply_sorted(2,:)>py;
        x_dir_pos = find(x_dir_int, 1, 'first');
        y_dir_pos = find(y_dir_int, 1, 'first');
        [~, type] = min([x_dir_pos, num_poly_points-x_dir_pos, y_dir_pos, num_poly_points-y_dir_pos]);
        %%
        switch type
            % -x
            case 1
                %%
                %%%DEBUG
%                 in(idp) = false;
                %%%
                xtocheck = sort(ply_idx(1, (1:x_dir_pos-1)));
                %%% find critical edges
                xcrit = diff(xtocheck)~=1;
                xcrit_points = [xtocheck([xcrit false]) xtocheck([false xcrit])-1; xtocheck([xcrit false])+1 xtocheck([false xcrit])];

                if xtocheck(1) > 1 
                    xcrit_points = [[xtocheck(1)-1; xtocheck(1)], xcrit_points];
                elseif xtocheck(end)~=num_poly_points
                    xcrit_points = [[num_poly_points; 1], xcrit_points];
                end
                if xtocheck(end) < num_poly_points
                    xcrit_points = [xcrit_points, [xtocheck(end); xtocheck(end)+1]];
                elseif xtocheck(1)~=1
                    xcrit_points = [[num_poly_points; 1], xcrit_points];
                end
                %%% test preedge if exist
                for idcrit = 1:size(xcrit_points, 2)
                    v1 = poly(:,xcrit_points(1,idcrit));
                    v2 = poly(:,xcrit_points(2,idcrit));
                    % calculate intersection and det(pv2, pv1) to see if point is on the right side of the edge
                    if ((v1(2)>py) ~= (v2(2)>py)) 
                        side = px-v1(1)-((v2(1)-v1(1))*(py-v1(2)))/(v2(2)-v1(2));
                        if side>0
                            in(idp) = ~in(idp);
%                             fprintf(1, 'in=%d, idcrit=%d, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), idcrit, v1(1), v1(2), v2(1), v2(2));
                        end
                    end
                end
                %%%
                for idch = 2:numel(xtocheck)
                    % test for edge
                    if xtocheck(1,idch-1)==xtocheck(1,idch)-1
                    % only short test for intersection
                    % if point is on the boundary (parallel line) then
                    % there is no intersection 
                    if (((poly(2,xtocheck(1,idch-1))>py)&&(poly(2,xtocheck(1,idch))<py)))||(((poly(2,xtocheck(1,idch-1))<py)&&(poly(2,xtocheck(1,idch))>py)))
                        in(idp) = ~in(idp);
%                         fprintf(1, 'in=%d, idch=%d, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), idch, poly(1,xtocheck(1,idch-1)), poly(2,xtocheck(1,idch-1)),  poly(1,xtocheck(1,idch)), poly(2,xtocheck(1,idch)));
                    end
                    end
                end
                    % insert missing edge if needed
                if (xtocheck(1)==1 && xtocheck(end)==num_poly_points)
                    if (((poly(2,xtocheck(1,end))>py)&&(poly(2,xtocheck(1,1))<py)))||(((poly(2,xtocheck(1,end))<py)&&(poly(2,xtocheck(1,1))>py)))
                        in(idp) = ~in(idp);
%                         fprintf(1, 'in=%d, id=last, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), poly(1,xtocheck(1,idch-1)), poly(2,xtocheck(1,idch-1)),  poly(1,xtocheck(1,idch)), poly(2,xtocheck(1,idch)));
                    end
                end
                
            case 2
                %% x
                %%include possible equal x point on xline
                if ply_sorted(1,x_dir_pos-1)==px
                    x_dir_pos = x_dir_pos -1;
                end

                xtocheck = sort(ply_idx(1, (x_dir_pos:num_poly_points)));
                %%% find critical edges
                xcrit = diff(xtocheck)~=1;
                xcrit_points = [xtocheck([xcrit false]) xtocheck([false xcrit])-1; xtocheck([xcrit false])+1 xtocheck([false xcrit])];

                if xtocheck(1) > 1 
                    xcrit_points = [[xtocheck(1)-1; xtocheck(1)], xcrit_points];
                elseif xtocheck(end)~=num_poly_points
                    xcrit_points = [[num_poly_points; 1], xcrit_points];
                end
                if xtocheck(end) < num_poly_points
                    xcrit_points = [xcrit_points, [xtocheck(end); xtocheck(end)+1]];
                elseif xtocheck(1)~=1
                    xcrit_points = [[num_poly_points; 1], xcrit_points];
                end
                
                %% test preedge if exist
                for idcrit = 1:size(xcrit_points, 2)
                    v1 = poly(:,xcrit_points(1,idcrit));
                    v2 = poly(:,xcrit_points(2,idcrit));
                    % calculate intersection and det(pv2, pv1) to see if point is on the right side of the edge
                    if ((v1(2)>py) ~= (v2(2)>py)) 
                        side = px-v1(1)-((v2(1)-v1(1))*(py-v1(2)))/(v2(2)-v1(2));
                        if side<0
                            in(idp) = ~in(idp);
%                             fprintf(1, 'in=%d, idcrit=%d, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), idcrit, v1(1), v1(2), v2(1), v2(2));
                        end
                    end
                end
                %%%
                for idch = 2:numel(xtocheck)
                    % test for edge
                    if xtocheck(1,idch-1)==xtocheck(1,idch)-1
                    % only short test for intersection
                    % if point is on the boundary (parallel line) then
                    % there is no intersection 
                    if (((poly(2,xtocheck(1,idch-1))>py)&&(poly(2,xtocheck(1,idch))<py)))||(((poly(2,xtocheck(1,idch-1))<py)&&(poly(2,xtocheck(1,idch))>py)))
                        in(idp) = ~in(idp);
%                         fprintf(1, 'in=%d, idch=%d, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), idch, poly(1,xtocheck(1,idch-1)), poly(2,xtocheck(1,idch-1)),  poly(1,xtocheck(1,idch)), poly(2,xtocheck(1,idch)));
                    end
                    end
                end
                    % insert missing edge if needed
                if (xtocheck(1)==1 && xtocheck(end)==num_poly_points)
                    if (((poly(2,xtocheck(1,end))>py)&&(poly(2,xtocheck(1,1))<py)))||(((poly(2,xtocheck(1,end))<py)&&(poly(2,xtocheck(1,1))>py)))
                        in(idp) = ~in(idp);
%                         fprintf(1, 'in=%d, id=last, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), poly(1,xtocheck(1,idch-1)), poly(2,xtocheck(1,idch-1)),  poly(1,xtocheck(1,idch)), poly(2,xtocheck(1,idch)));
                    end
                end
                % -y
            case 3
                %% -y
                ytocheck = sort(ply_idx(2, (1:y_dir_pos-1)));
                %%% find critical edges
                ycrit = diff(ytocheck)~=1;
                ycrit_points = [ytocheck([ycrit false]) ytocheck([false ycrit])-1; ytocheck([ycrit false])+1 ytocheck([false ycrit])];

                if ytocheck(1) > 1 
                    ycrit_points = [[ytocheck(1)-1; ytocheck(1)], ycrit_points];
                elseif ytocheck(end)~=num_poly_points
                    ycrit_points = [[num_poly_points; 1], ycrit_points];
                end
                if ytocheck(end) < num_poly_points
                    ycrit_points = [ycrit_points, [ytocheck(end); ytocheck(end)+1]];
                elseif ytocheck(1)~=1
                    ycrit_points = [[num_poly_points; 1], ycrit_points];
                end
                
                %% test preedge if exist
                for idcrit = 1:size(ycrit_points, 2)
                    v1 = poly(:,ycrit_points(1,idcrit));
                    v2 = poly(:,ycrit_points(2,idcrit));
                    % calculate intersection and det(pv2, pv1) to see if point is on the right side of the edge
                    if ((v1(1)>px) ~= (v2(1)>px)) 
                        side = py-v1(2)-((v2(2)-v1(2))*(px-v1(1)))/(v2(1)-v1(1));
                        if side>0
                            in(idp) = ~in(idp);
%                             fprintf(1, 'in=%d, idcrit=%d, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), idcrit, v1(1), v1(2), v2(1), v2(2));
                        end
                    end
                end

                %%%
                for idch = 2:numel(ytocheck)
                    % test for edge
                    if ytocheck(1,idch-1)==ytocheck(1,idch)-1
                    % only short test for intersection
                    % if point is on the boundary (parallel line) then
                    % there is no intersection 
                    if (((poly(1,ytocheck(1,idch-1))>px)&&(poly(1,ytocheck(1,idch))<px)))||(((poly(1,ytocheck(1,idch-1))<px)&&(poly(1,ytocheck(1,idch))>px)))
                        in(idp) = ~in(idp);
%                         fprintf(1, 'in=%d, idch=%d, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), idch, poly(1,ytocheck(1,idch-1)), poly(2,ytocheck(1,idch-1)),  poly(1,ytocheck(1,idch)), poly(2,ytocheck(1,idch)));
                    end
                    end
                end
                    % insert missing edge if needed
                if (ytocheck(1)==1 && ytocheck(end)==num_poly_points)
                    if (((poly(1,ytocheck(1,1))>px)&&(poly(1,ytocheck(1,end))<px)))||(((poly(1,ytocheck(1,1))<px)&&(poly(1,ytocheck(1,end))>px)))
                        in(idp) = ~in(idp);
%                         fprintf(1, 'in=%d, id=last, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), poly(1,xtocheck(1,1)), poly(2,xtocheck(1,1)),  poly(1,xtocheck(1,end)), poly(2,xtocheck(1,end)));
                    end
                end
                % y
            case 4
                %% include possible equal x point on xline
                if ply_sorted(2,y_dir_pos-1)==py
                    y_dir_pos = y_dir_pos -1;
                end
                                %% y
                ytocheck = sort(ply_idx(2, (y_dir_pos:num_poly_points)));
                %%% find critical edges
                ycrit = diff(ytocheck)~=1;
                ycrit_points = [ytocheck([ycrit false]) ytocheck([false ycrit])-1; ytocheck([ycrit false])+1 ytocheck([false ycrit])];

                if ytocheck(1) > 1 
                    ycrit_points = [[ytocheck(1)-1; ytocheck(1)], ycrit_points];
                elseif ytocheck(end)~=num_poly_points
                    ycrit_points = [[num_poly_points; 1], ycrit_points];
                end
                if ytocheck(end) < num_poly_points
                    ycrit_points = [ycrit_points, [ytocheck(end); ytocheck(end)+1]];
                elseif ytocheck(1)~=1
                    ycrit_points = [[num_poly_points; 1], ycrit_points];
                end
                
                %% test preedge if exist
                for idcrit = 1:size(ycrit_points, 2)
                    v1 = poly(:,ycrit_points(1,idcrit));
                    v2 = poly(:,ycrit_points(2,idcrit));
                    % calculate intersection and det(pv2, pv1) to see if point is on the right side of the edge
                    if ((v1(1)>px) ~= (v2(1)>px)) 
                        side = py-v1(2)-((v2(2)-v1(2))*(px-v1(1)))/(v2(1)-v1(1));
                        if side<0
                            in(idp) = ~in(idp);
%                             fprintf(1, 'in=%d, idcrit=%d, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), idcrit, v1(1), v1(2), v2(1), v2(2));
                        end
                    end
                end

                %%%
                for idch = 2:numel(ytocheck)
                    % test for edge
                    if ytocheck(1,idch-1)==ytocheck(1,idch)-1
                    % only short test for intersection
                    % if point is on the boundary (parallel line) then
                    % there is no intersection 
                    if (((poly(1,ytocheck(1,idch-1))>px)&&(poly(1,ytocheck(1,idch))<px)))||(((poly(1,ytocheck(1,idch-1))<px)&&(poly(1,ytocheck(1,idch))>px)))
                        in(idp) = ~in(idp);
%                         fprintf(1, 'in=%d, idch=%d, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), idch, poly(1,ytocheck(1,idch-1)), poly(2,ytocheck(1,idch-1)),  poly(1,ytocheck(1,idch)), poly(2,ytocheck(1,idch)));
                    end
                    end
                end
                    % insert missing edge if needed
                if (ytocheck(1)==1 && ytocheck(end)==num_poly_points)
                    if (((poly(1,ytocheck(1,1))>px)&&(poly(1,ytocheck(1,end))<px)))||(((poly(1,ytocheck(1,1))<px)&&(poly(1,ytocheck(1,end))>px)))
                        in(idp) = ~in(idp);
%                         fprintf(1, 'in=%d, id=last, x1=%g, y1=%g, x2=%g, y2=%g\n', in(idp), poly(1,xtocheck(1,1)), poly(2,xtocheck(1,1)),  poly(1,xtocheck(1,end)), poly(2,xtocheck(1,end)));
                    end
                end

        end
        
        
    else
        in(idp) = false;
    end
end




function [xlim, ylim, plim, qlim] = comp_bb_bp(poly)
%%
xlim = [ min(poly(1,:)), max(poly(1,:)) ];
ylim = [ min(poly(2,:)), max(poly(2,:)) ];
plim = [ min(poly(1,:)+poly(2,:)), max(poly(1,:)+poly(2,:)) ];
qlim = [ min(poly(1,:)-poly(2,:)), max(poly(1,:)-poly(2,:)) ];
% axy = diff(x)*diff(y);
% apq = diff(p)*diff(q);
