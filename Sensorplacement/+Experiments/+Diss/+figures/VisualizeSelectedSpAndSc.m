plot(cellfun(@(x) numel(x.sc_selected), all_eval.conference_room.sco(:)))
plot(cellfun(@(x) numel(x.sc_selected), all_eval.small_flat.sco(:)))
plot(cellfun(@(x) numel(x.sc_selected), all_eval.large_flat.sco(:)))
plot(cellfun(@(x) numel(x.sc_selected), all_eval.office_floor.sco(:)))

%%
mesh(cellfun(@(x) numel(x.sc_selected), all_eval.conference_room.sco))
mesh(cellfun(@(x) numel(x.sc_selected), all_eval.small_flat.sco))
mesh(cellfun(@(x) numel(x.sc_selected), all_eval.large_flat.sco))
mesh(cellfun(@(x) numel(x.sc_selected), all_eval.office_floor.sco))
%%
%%
mesh(cellfun(@(x) numel(x.sensors_selected), all_eval.conference_room.sco_it))
mesh(cellfun(@(x) numel(x.sensors_selected), all_eval.conference_room.sco))

surf(cellfun(@(x, y) numel(x.sensors_selected)-numel(y.sensors_selected), all_eval.conference_room.sco, all_eval.conference_room.sco_it))

surf(cellfun(@(x, y) numel(x.sensors_selected)-numel(y.sensors_selected), all_eval.conference_room.gsss, all_eval.conference_room.gsss_it))

scodiff = (cellfun(@(x, y) numel(x.sensors_selected)-numel(y.sensors_selected), all_eval.conference_room.sco, all_eval.conference_room.sco_it))
sum(scodiff(:)>0 & scodiff(:)<=1)
sum(scodiff(:)>1 & scodiff(:)<=2)