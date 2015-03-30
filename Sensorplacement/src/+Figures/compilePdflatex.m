function compilePdflatex(figurename, exportToDiss, compile)
% lua_command = 'lualatex --synctex=1 ';
tex_fullname = figurename;
pdf_fullname = strrep(figurename, '.tex', '.pdf');

output_folder = 'export/';
lua_command = 'pdflatex --synctex=1 ';
cd(output_folder);
system([lua_command figurename]);
cd ..

diss_folder = '../../Dissertation/Thesis/';
figures_folder = [diss_folder 'Figures/'];

%   copyfile([output_folder figure_fullname], [diss_folder figure_fullname]);
if nargin > 1 && exportToDiss
    copyfile([output_folder figurename], [figures_folder tex_fullname]);
    copyfile([output_folder pdf_fullname], [figures_folder pdf_fullname]);
    if nargin > 2 && compile
        system(['latexmk -cd -pdflatex="pdflatex.exe -interaction=nonstopmode -file-line-error -synctex=1" -pdf ' diss_folder 'Diss_Kirchhof.tex']);
        system(['SumatraPDF.bat '  diss_folder 'Diss_Kirchhof.pdf']);
    end
else
    system(['SumatraPDF.bat '  output_folder pdf_fullname]);
end
