function export_all2tikz
%% export all figures to thesis

thesisdir = [getenv('home') '\Workspace\nico.staff\Thesis\Figures\.'];

files = dir('*.fig');
for idf = 1:numel(files)
    openfig(files(idf).name);
    matlab2tikz( [files(idf).name '.tikz'], 'height', '\figureheight', 'width', '\figurewidth' );
end

movefile('*.tikz', thesisdir, 'f');