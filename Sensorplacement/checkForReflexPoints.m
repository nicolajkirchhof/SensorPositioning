function reflex_points = checkForReflexPoints(edges)
% calculates if any of the points of two merged edges are reflex
%% Test the angles between edges that originate from the same point

reflex_points = {};
for id_edge = 1:2
    if ~edges{id_edge}.is_merged
        %%
        id_other_edge = mod(id_edge, 2)+1;
        
        ang_en = edgeAngle([edges{id_edge}.begin edges{id_other_edge}.begin]);
        ang_2_1 = edgeAngle([edges{id_edge}.begin edges{id_edge}.points(1,:)]);
        ang_2_3 = edgeAngle([edges{id_edge}.begin edges{id_edge}.points(3,:)]);
        
        %     diff_1_3 = normalizeAngle(angleDiff(ang_2_1, ang_2_3));
        %     diff_3_1 = normalizeAngle(angleDiff(ang_2_3, ang_2_1));
        
        reflex_point = edges{id_edge};
        reflex_point.normal = [];
        %% order is 3, en, 1
        diff_3_en = normalizeAngle(angleDiff(ang_2_3, ang_en));
        diff_en_1 = normalizeAngle(angleDiff(ang_en, ang_2_1));
        
        if diff_3_en > pi
            reflex_point.normal = normalizeAngle(ang_2_3+diff_3_en/2);
        elseif diff_en_1 > pi
            reflex_point.normal = normalizeAngle(ang_en+diff_en_1/2);
        end
        
        if ~isempty(reflex_point.normal)
            reflex_points{end+1} = reflex_point;
        end
    end
end


return;

%% TEST positive case
e1 = [];
e1.points = [
    8479,        5753;
    2140,        5753;
    2140,        7723];
e1.begin = e1.points(2, :);

e2 = [];
e2.points = [
    2140        1383
    2140        3353
    8479        3353];
e2.begin = e2.points(2, :);

edges = {e1, e2};

if ~isempty(checkForReflexPoints(edges))
    error('Test Fails');
end
%% Test creation case
e1 = [];
e1.points = [
    8479,        5753;
    2140,        5753;
    2500,        7723];
e1.begin = e1.points(2, :);

e2 = [];
e2.points = [
    2140        1383
    2140        3353
    8479        3353];
e2.begin = e2.points(2, :);

edges = {e1, e2};

reflex_points = checkForReflexPoints(edges);

if ~(length(checkForReflexPoints(edges)) == 1)
    error('Test Fails');
end