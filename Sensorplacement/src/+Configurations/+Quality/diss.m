function quality = diss()
%% GENERIC generic configuration of quality parameters

types = Configurations.Quality.get_types();
quality.type = types.diss;

quality.sensor = Configurations.Sensor.tpl;
quality.ws = 'distance';
quality.wss = 'kirchhof';
%%
