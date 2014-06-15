function quality = generic()
%% GENERIC generic configuration of quality parameters

types = Configurations.Quality.get_types();
quality.type = types.generic;

quality.ws = [];
quality.wss = [];

%%
