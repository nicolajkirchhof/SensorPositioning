% computes the angle between the two lines p1-p2 and p2-p3  
function a = angle3PointsFast(p1, p2, p3)

% da2 = sum((p2-p1).^2);
% db2 = sum((p2-p3).^2);
% dc2 = sum((p1-p3).^2);
da2 = sum(bsxfun(@minus, p2, p1).^2, 1);
db2 = sum(bsxfun(@minus, p2, p3).^2, 1);
dc2 = sum(bsxfun(@minus, p1, p3).^2, 1);

% if da2<0 || db2<0
%     disp([da2 db2 dc2]);
% end

% if da2==db2
% %     a = acos((2*da2-dc2)/(2*da2));
%     a = acos(1-(dc2/(2*da2)));
% else
in = (da2+db2-dc2)./(2*sqrt(da2.*db2));
    a = acos(in);
    if ~isreal(a)
        in(in>-(1+10*eps) & in<-1) = -1;
        in(in<(1+10*eps) & in>1) = 1;
        if any(in<-1 | in>1)
            error('true imagine???');
        end
        a = acos(in);
    end
% end