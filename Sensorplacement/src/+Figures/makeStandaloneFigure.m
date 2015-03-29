function makeStandaloneFigure(figurename, width, height, heightonly)

if nargin == 2 && isempty(width)
    %%
    width = '11cm';
end
figure_fullname = [figurename '.tikz'];
tex_fullname = [figurename '.tex'];
pdf_fullname = [figurename '.pdf'];
%%
output_folder = 'export/';
filename = [output_folder tex_fullname];
cleanfigure();

if nargin > 3
    matlab2tikz(filename, 'parseStrings', false,...
        'height', height, ...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
elseif nargin > 2
    matlab2tikz(filename, 'parseStrings', false,...
        'width', width,...
        'height', height, ...
        'extraAxisOptions',{'y post scale=1'},...
        'standalone', true);
elseif nargin > 1
    matlab2tikz(filename, 'parseStrings', false,...
        'width', width,...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'extraAxisOptions',{'y post scale=1'},...
        'standalone', true);
else
    matlab2tikz(filename, 'parseStrings', false)%,...
    
end
%%

% lua_command = 'lualatex --synctex=1 ';
lua_command = 'pdflatex --synctex=1 ';
cd(output_folder);
system([lua_command tex_fullname]);
cd ..

diss_folder = '../../Dissertation/Thesis/Figures/';

%   copyfile([output_folder figure_fullname], [diss_folder figure_fullname]);
copyfile(filename, [diss_folder tex_fullname]);
copyfile([output_folder pdf_fullname], [diss_folder pdf_fullname]);
system(['SumatraPDF.bat '  output_folder pdf_fullname]);