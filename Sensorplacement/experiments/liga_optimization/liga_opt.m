%% optimize liga
srequest = 'http://maps.googleapis.com/maps/api/distancematrix/json?origins=%s&destinations=%s&sensor=false';
cities_l1 = {'Wuerselen','Aachen','Dueren','Ratheim','Euskirchen','Gemuend','Bruehl','Fischenich','Spich','Mondorf'};
cities_l2 = {'Neuss','Eichen-Kreuztal','Moers','Kamp-Lintfort','Heiligenhaus','Solingen','Langenfeld','Hilden','Lintorf','Wuppertal'};
cities_l3 = {'Bochum','Schwelm','Epe','Gladbeck','Coesfeld','Essen','Essen','Muenster','Mesum','Emsdetten'};
cities_l4 = {'Dortmund','Dortmund','Guetersloh','Bielefeld','Oerlinghausen','Lage','Herford','Altenbeken','Werne','Everswinkel'};
cities_all = [cities_l1, cities_l2, cities_l3, cities_l4];
num_cities = numel(cities_all);
%%
city_distance_requests = cell(1,num_cities-1);
for idfrom = 1:num_cities-1
    city_from = [cities_all{idfrom} '+Germany'];
    cities_to = [cities_all{idfrom+1} '+Germany'];
    for idc = idfrom+2:num_cities
        cities_to = sprintf('%s|%s+Germany', cities_to, cities_all{idc});
    end    
    city_distance_requests{idfrom} = sprintf(srequest, city_from, cities_to);
end


city_distance_answers = cell(1,num_cities-1);
city_distance_jsons = cell(1,num_cities-1);
%%
for idr = 6:numel(city_distance_requests)
    city_distance_answers{idr} = urlread(city_distance_requests{idr});
    city_distance_jsons{idr} = loadjson(city_distance_answers{idr});
    pause(5);
end
%%
distance_matrix = zeros(num_cities);
for idrow = 1:numel(city_distance_jsons)
    for idcol = idrow+1:num_cities
        distance_matrix(idrow, idcol) = city_distance_jsons{idrow}.rows(1).elements(idcol-idrow).distance.value;
    end
end    
%%
num_leagues = 4;
num_cities = 20;
num_city_league_comb = num_cities*num_leagues;

c_il_obj = zeros(num_city_league_comb, 1); % city league combinations
c_il_A = ones(num_cities, num_city_league_comb);
c_il_A_row = zeros(1,num_city_league_comb);
c_il_A_row(1:num_leagues) = 1;
for idcity = 1:num_cities
    c_il_A(idcity,:) =  circshift(c_il_A_row, [0 ((idcity-1)*num_leagues)]);
end
c_il_lrhs = ones(num_cities, 1);
c_il_ctype = repmat('B', 1, num_city_league_comb);
c_il_ub = ones(num_city_league_comb,1);
c_il_lb = zeros(num_city_league_comb,1);
%%% constraints for the number of teams per leage
c_num_l_A = zeros(num_leagues, num_city_league_comb);
c_num_l_lrhs = (num_cities/num_leagues)*ones(num_leagues,1);
for idl = 1:num_leagues
    c_num_l_A(idl, idl:num_leagues:num_city_league_comb) = 1;
end

%%%
e_ikl_comb = comb2unique(1:num_cities);
num_comb = size(e_ikl_comb, 1);
% num_city_league_city_comb = num_city_league_comb*num_cities;
e_ikl = zeros(num_comb, 1);
e_ikl_A = zeros(num_comb*3*num_leagues, num_city_league_comb+(num_comb*num_leagues));
e_ikl_lhs = -inf(num_comb*3*num_leagues, 1);
e_ikl_rhs = inf(num_comb*3*num_leagues, 1);
e_ikl_obj = repmat(distance_matrix(sub2ind(size(distance_matrix), e_ikl_comb(:,1), e_ikl_comb(:,2))), 1, num_leagues)';
e_ikl_obj = e_ikl_obj(:);
e_ikl_ub = ones(num_comb*num_leagues, 1);
e_ikl_lb = zeros(num_comb*num_leagues, 1);
e_ikl_ctype= repmat('B', 1, num_comb*num_leagues);
iducomb = 1;
idcombvar = num_city_league_comb+1;
for idc = 1:size(e_ikl_comb, 1)
%     iducomb = ((idc-1)*3*num_leagues)+1;
    % city combination are only choosen if cities are in the same league
    idcities = ((e_ikl_comb(idc,:)-1)*num_leagues)+1;
%     idcombvar = idc+num_city_league_comb+num_leagues*(idc-1);
    for idleagues = 0:num_leagues-1
        e_ikl_A(iducomb, idcities(1)+idleagues) = -1;
        e_ikl_A(iducomb, idcombvar) = 1;
        e_ikl_rhs(iducomb) = 0;
        iducomb = iducomb +1;
    e_ikl_A(iducomb, idcities(2)+idleagues) = -1;
    e_ikl_A(iducomb, idcombvar) = 1;
    e_ikl_rhs(iducomb) = 0;
    iducomb = iducomb+1;
    e_ikl_A(iducomb, idcities+idleagues) = 1;
    e_ikl_A(iducomb, idcombvar) = -1;
    e_ikl_rhs(iducomb) = 1;
    iducomb = iducomb+1;
    idcombvar = idcombvar+1;
    end
end
%
% cp = Cplex('leagues');
%%%
% cp.Model.A = [ c_il_A;
%     c_num_l_A];
% cp.Model.lhs= [c_il_lrhs; c_num_l_lrhs];
% cp.Model.rhs= [c_il_lrhs; c_num_l_lrhs];
% cp.Model.obj= [c_il_obj];
% cp.Model.ctype = [c_il_ctype];
% cp.Model.ub = [c_il_ub];
% cp.Model.lb = [c_il_lb];
% %%
cp.Model.A = [ c_il_A, zeros(num_cities, num_comb*num_leagues);
    c_num_l_A, zeros(num_leagues, num_comb*num_leagues);
    e_ikl_A];
cp.Model.lhs= [c_il_lrhs; c_num_l_lrhs; e_ikl_lhs];
cp.Model.rhs= [c_il_lrhs; c_num_l_lrhs; e_ikl_rhs];
cp.Model.obj= [c_il_obj; e_ikl_obj];
cp.Model.ctype = [c_il_ctype, e_ikl_ctype];
cp.Model.ub = [c_il_ub; e_ikl_ub];
cp.Model.lb = [c_il_lb; e_ikl_lb];
% cp.solve();
%%


