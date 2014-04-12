function pc = sensorcomb(pc)
%% Builds all sensor combinations for every workspace point
% use straight forward sum(n-1:n-i1)-(n-i2) to calculate intersection index
% combinations that are not valid due to sameplace constraints are excluded

if ~pc.progress.sensorspace.visibility
    pc = sensorspace.visibility(pc);
end
if ~pc.progress.sensorspace.sameplace
    pc = sensorspace.sameplace(pc);
end

if pc.problem.num_positions > intmax('uint16') || pc.problem.num_sensors > intmax('uint16')
    error('only %d positions supported due to data type', intmax('uint16'));
end
%%
num_sensors = pc.problem.num_sensors;
sc_ij = false(num_sensors);

% make sure previous file is closed
if pc.common.tmpfile.wp_sc_idx.fid > 0
     pc.common.tmpfile.wp_sc_idx.fid = fclose(pc.common.tmpfile.wp_sc_idx.fid);
end
%%% estimate combination matrix size
% estimated number of combinations from visible sensors for each point
    % wp_sc_cache is the matrix that stores for every workspace point (columns)
    % a one if it is seen by the sensor cobination (rows) since matlab stores the
    % matrices columnwise, this provides fast access to all combination that sees a wp
    % The problem is that the number of combinations that is needed is not known in advance
    % due to the many sensor combinations that are non-intersecting.
    % The matrix is therefore sliced into pieces and written to a file. The start addresses of
    % submatrices and their lenght are stored in pc the file will look like this
    % [ c1r1 ... c1rM c2r1 ... c2rM ... c1rM+1 ... c1rM+M c2rM+1 ... c2rM+M ... ]
    % one 8 bit entry per combination element
    % The matrix is stored columnwise, therefore the appropriate space
    % for each column must be known in advance, which is not, due to the
    num_slice_rows = floor(pc.common.workmem/pc.problem.num_positions);
    wp_sc_cache = zeros(num_slice_rows, pc.problem.num_positions, 'uint8');
xt_ji = pc.problem.xt_ij'; % use transposed matrix since column operations are much faster
loop_display(num_sensors, 10);
if pc.common.is_logging, write_log('calculating all qualities for every workspace point'); end
%%
cnt = 1;
% num_comb = 1;
num_slices = 1;
for ids = 1:num_sensors
    %% finds all the used combinations from the xt_ij matrix
    % the idea is to move through all sensor rows and and them with the current sensor row
    % if there are no common points the resulting vector is all false
    for ids2 = ids+1:num_sensors
        if any(xt_ji(:, ids)&xt_ji(:,ids2)) && ~pc.problem.sp_ij(ids, ids2)
            sc_ij(ids, ids2) = 1;
            combs = xt_ji(:, ids)&xt_ji(:,ids2);
            % sc_wp_idx{ids, ids2} = uint16(find(combs)); % profile 21.131s
            %             wp_sc_cache(cnt, :) = combs;
            wp_sc_cache(cnt, combs) = 1;
            cnt = cnt + 1;
            %             num_comb = num_comb+1;
            if cnt > num_slice_rows                
                % we've reached the max matrix size therefore the matrix is written to
                % a file
                if pc.common.tmpfile.wp_sc_idx.fid < 1
                    write_log('matrix size too big, using tempfile');
                    % first time, open file
                    pc.common.tmpfile.wp_sc_idx.fid = fopen(pc.common.tmpfile.wp_sc_idx.name, 'W');
                end
                fwrite(pc.common.tmpfile.wp_sc_idx.fid, wp_sc_cache);
                wp_sc_cache = zeros(num_slice_rows, pc.problem.num_positions, 'uint8');
                num_slices = num_slices + 1;
                cnt = 1;
            end
        end
    end
    loop_display(ids);
end
if cnt > 1 && pc.common.tmpfile.wp_sc_idx.fid > 0
    fwrite(pc.common.tmpfile.wp_sc_idx.fid, wp_sc_cache(1:cnt-1, :));
    num_slices = num_slices + 1;
end
write_log('Calculation finished');
%%
pc.problem.sc_ij = sc_ij;
[c1, c2] = find(sc_ij);
pc.problem.sc_idx = uint16(sortrows([c1, c2]));
% sc_ind = sub2ind(size(sc_wp_idx), uint64(pc.problem.sc_idx(:,1)), uint64(pc.problem.sc_idx(:,2)));
%%%
% reduce variable size by selecting only non empty cells
% pc.problem.sc_wp_idx = sc_wp_idx(sc_ind);
pc.problem.num_comb = size(pc.problem.sc_idx, 1);
% pc.problem.num_comb = num_comb;
% pc.problem.sc_wp_idx2 = sc_wp_idx2;
% whos_prettyprint;
% set progress
%%%
if pc.common.tmpfile.wp_sc_idx.fid > 1
fclose(pc.common.tmpfile.wp_sc_idx.fid);
% prevent changes
pc.common.tmpfile.wp_sc_idx.fid = fopen(pc.common.tmpfile.wp_sc_idx.name, 'r');
pc.problem.wp_sc_idx = @(r, c) sliced_read(c, pc.common.tmpfile.wp_sc_idx.fid, num_slices, num_slice_rows, pc.problem.num_positions, pc.problem.num_comb);
else
    pc.problem.wp_sc_idx = wp_sc_cache(1:pc.problem.num_comb, :);
end
%%%
pc.progress.sensorspace.sensorcomb = 1;

return;

%% test tmp file
if pc.problem.num_comb >= intmax('uint32')
    error('test must be redefined')
end
loop_display(pc.problem.num_positions, 10);
write_log('checking all qualities for every workspace point');
for idw = 1:pc.problem.num_positions
    sc_file = find(pc.problem.wp_sc_idx(idw));
    sc_mat = {};
    for idc = 1:pc.problem.num_comb
        if any(pc.problem.sc_wp_idx{idc} == idw)
            sc_mat{end+1, 1} = idc;
        end
    end
    sc_mat = sort(cell2mat(sc_mat));
    %%     if ~isempty(setdiff(sc_file, sc_mat))
    if any(sc_file~=sc_mat)
        %%
        figure, plot(1:numel(sc_mat), sc_mat, 'og');
        hold on;
        plot(1:numel(sc_file), sc_file, 'or');
        %%
        error('investigate');
    end
    loop_display(idw);
end
write_log('all good');
%%
%
% frewind(pc.common.tmpfile.wp_sc_idx.fid);
% loop_display(pc.problem.num_comb, 10);
% write_log('checking all qualities for every workspace point');
% for idw = 1:pc.problem.num_comb
%     ids = fread(pc.common.tmpfile.wp_sc_idx.fid, pc.problem.num_positions, 'uint8');
%     if ~isempty(setdiff(find(ids), pc.problem.sc_wp_idx{idw}))
%         %%
%         figure, plot(1:numel(pc.problem.sc_wp_idx{idw}), pc.problem.sc_wp_idx{idw}, 'og');
%         hold on;
%         plot(1:numel(find(ids)), find(ids), 'or');
%         %%
% %         error('investigate');
%     end
%     loop_display(idw);
% end
% write_log('all good');
