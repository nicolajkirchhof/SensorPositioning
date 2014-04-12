function ccw = polygonIsCounterClockwise(pts)

if size(pts,1) > 3
    [~, pts_sort_idx] = sortrows(pts);
    max_pt_idx = pts_sort_idx(end);
    sec_pos_shift = -(max_pt_idx-2);
    %% cycle pts to have the max point at 2nd position
    pts = circshift(pts, [sec_pos_shift 0]);
end

    ccw = isCounterClockwise(pts(1,:),pts(2,:),pts(3,:));
    