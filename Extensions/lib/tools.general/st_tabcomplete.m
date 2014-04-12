% set(0, 'DefaultFigurePosition', get(0, 'FactoryFigurePosition'));
def = tabcomplete('st');
%%
if isempty(def)
    tabcomplete('st', 'file');
    exit
end