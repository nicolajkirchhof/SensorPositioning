function writeTexFile(tikzfilename, output_folder)

tex_fullname = strrep(tikzfilename, 'tikz', 'tex');
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

    fun_fpf(['\\input{' tikzfilename '}']);

  fun_fpf('\\end{document}');
  
  fclose(fid);