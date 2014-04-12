function annulus_segment = createAnnulusSegment(x,y,di,do,phi,dphi, nverticies)
%% annulus_segment = createAnnulusSegment(x,y,di,do,phi,dphi, nverticies)
% returns the annulus segment as a polygon the segment ist defined by
% x,y:      the center of the circle for which the annulus is taken
% di, do:   the inner and outer distance from the circle center
% phi, dphi:the offset and the circular length of the annulus segment in deg
% nverticies: the number of verticies that is used for the circle arcs

% unique is needed, since the inner arc is allowed to have dist 0, which
% leads to calculation of a circle segment
fun_createCircleArc = @(dist)...
    unique(circleArcToPolyline([[x y], dist, phi, dphi], nverticies), 'rows', 'stable')';
inner_circle_arc = fliplr(fun_createCircleArc(di));
outer_circle_arc = fun_createCircleArc(do);
%% create closed polygon
annulus_segment = [inner_circle_arc, outer_circle_arc, inner_circle_arc(:,1)];
