function [btriag_out] = triangleSplit(btriag, max_length)
%polygonArea for boost polygon
%%
lines = double(bsxfun(@minus, btriag(:,2:end)', btriag(:,1:end-1)'));
line_lengths = hypot(lines(:,1), lines(:,2));
%define id shift vector
ids = [1,2,3]';
[max_line, shiftlength] = max(line_lengths);
% shift to order in right direction for inserting middlept
ids = circshift(ids, -(shiftlength-1));
if max_line > max_length
    middlept = btriag(:,ids(1))+int64(0.5*lines(ids(1),:))';
    newtriags = {[btriag(:,ids(1)), middlept, btriag(:, ids(3)), btriag(:,ids(1))], [btriag(:,ids(2)), btriag(:, ids(3)), middlept, btriag(:,ids(2))]};
    
    fun_triangleSplit = @(x) mb.triangleSplit(x, max_length);
    newtriags = cellfun(fun_triangleSplit, newtriags, 'uniformoutput', false);
    btriag_out = mb.flattenPolygon(newtriags);
else
     btriag_out = {btriag};
end
