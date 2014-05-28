function wss_qualities(q)
cla, hold on;
for idw = 1:numel(q)
     plot3(ones(size(q{idw}))*idw, 1:numel(q{idw}), q{idw});
end
theme(gca, 'office', false);
