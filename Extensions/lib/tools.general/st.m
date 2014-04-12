function st (name)
if ispc
    userdir= getenv('USERPROFILE');
    sublime = [userdir '\PortableApps\SublimeText2.X.x64\sublime_text.exe'];
else
    error(' ');
end
if nargin < 1
    system([sublime ' &']);
    return;
end


found = exist(name);
if found>0
    if found == 2
        system([sublime ' ' name ' &']);
    end
    if found == 8
        file =  which(name);
        system([sublime ' ' file ' &']);
    end
end