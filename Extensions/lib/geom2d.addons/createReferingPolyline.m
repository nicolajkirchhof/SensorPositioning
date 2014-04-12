function pl = createReferingPolyline()
%% refering polyline is a reference to a part of an existing polyline the points hold the point coordinates,
% the references are the ring and point id within a polygon
pl.points = [];
pl.edges = [];
pl.multi_ids = [];
pl.ring_ids = [];
pl.point_ids = [];
pl.normal_angles = [];
pl.is_merged_cut = false;