function sol = solution(environment, discretization, quality, model,...
    config_environment, config_discretization, config_quality, config_model, solution)
%% solution(environment, discretization, quality, model,...
%    config_environment, config_discretization, config_quality, config_model) 

if nargin < 9 || isempty(solution)
    solution = [];
end
if nargin < 8 || isempty(config_model)
    config_model = [];
end
if nargin < 7 || isempty(config_quality)
    config_quality = [];
end
if nargin < 6 || isempty(config_discretization)
    config_discretization = [];
end
if nargin < 5 || isempty(config_environment)
    config_environment = [];
end
if nargin < 4 || isempty(model)
    model = [];
end
if nargin < 3 || isempty(quality)
    quality = [];
end
if nargin < 2 || isempty(discretization)
    discretization = [];
end
if nargin < 1 || isempty(environment)
    environment = [];
end


sol.discretization = discretization;
sol.environment = environment;
sol.model = model ;
sol.quality = quality;
sol.config.environment = config_environment;
sol.config.discretization = config_discretization;
sol.config.quality = config_quality;
sol.config.model = config_model;
sol.solution = solution;