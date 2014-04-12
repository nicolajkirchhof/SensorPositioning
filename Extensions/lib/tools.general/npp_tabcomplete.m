% set(0, 'DefaultFigurePosition', get(0, 'FactoryFigurePosition'));
def = tabcomplete('npp');
%%
if isempty(def)
    tabcomplete('npp', 'file');
    exit
end