function makeFigure(figurename, width, height, heightonly)

if nargin == 2 && isempty(width)
    %%
    width = '11cm';
end
figure_fullname = [figurename '.tikz'];
tex_fullname = [figurename '.tex'];
pdf_fullname = [figurename '.pdf'];
%%
output_folder = 'export/';
filename = [output_folder figure_fullname];

if nargin > 3 
    matlab2tikz(filename, 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-',... 
    'height', height, ...
    'extraAxisOptions',{'y post scale=1'});
elseif nargin > 2 
    matlab2tikz(filename, 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-',... 
    'width', width,...
    'height', height, ...
    'extraAxisOptions',{'y post scale=1'});
elseif nargin > 1
    matlab2tikz(filename, 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', width,...
...    'height', '5cm', 
    'extraAxisOptions',{'y post scale=1'});
else
    matlab2tikz(filename, 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-')%, %'width', width,...
...    'height', '5cm', 
    %'extraAxisOptions',{'y post scale=1'});
    
end

fid = fopen([output_folder tex_fullname], 'w');
fun_fpf = @(x) fprintf(fid, [x '\n']);

fun_fpf('%% -*- program: lualatex -*-');
fun_fpf('\\documentclass[a4paper]{scrreprt}');

fun_fpf('%% ********************************************************************');
fun_fpf('%% Everything related to TIKZ');
fun_fpf('%% ********************************************************************');
fun_fpf('\\PassOptionsToPackage{dvipsnames,svgnames}{xcolor}');
fun_fpf('\\usepackage[cmex10]{amsmath}');
fun_fpf('\\usepackage{pgfplots}');
  fun_fpf('\\pgfplotsset{compat=newest}');
  fun_fpf('\\pgfplotsset{plot coordinates/math parser=false}');
  fun_fpf('\\usetikzlibrary{shapes,graphdrawing,graphs,arrows,chains,backgrounds, graphdrawing.layered}');
  fun_fpf('\\usegdlibrary{force}');
  fun_fpf('\\usegdlibrary{trees}');
fun_fpf('\\pagestyle{empty}');
fun_fpf('\\usepackage[graphics,active,tightpage]{preview}');
fun_fpf('\\setlength\\PreviewBorder{2mm}');
fun_fpf('\\PreviewEnvironment{tikzpicture}');

  fun_fpf('\\begin{document}');

    fun_fpf(['\\input{' figure_fullname '}']);

  fun_fpf('\\end{document}');
  
  fclose(fid);
  %%
  
  lua_command = 'lualatex --synctex=1 ';
  cd(output_folder);
  system([lua_command tex_fullname]);
  cd ..
  
  diss_folder = '../../Dissertation/Thesis/Figures/';
  
  copyfile([output_folder figure_fullname], [diss_folder figure_fullname]);
  copyfile([output_folder pdf_fullname], [diss_folder pdf_fullname]);
  system(['SumatraPDF.bat '  output_folder pdf_fullname]);