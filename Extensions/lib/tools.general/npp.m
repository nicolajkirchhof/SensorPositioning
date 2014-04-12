function npp (name)
if nargin < 1
    error('what shal i do?')
end
if ispc
    userdir= getenv('USERPROFILE'); 
    notepad = [userdir '\PortableApps\Notepad++\Notepad++.exe'];
else
    error(' ');
%     userdir= getenv('HOME'); 
end
    found = exist(name);
    if found>0
        if found == 2
            system([notepad ' ' name ' &']);
        end
        if found == 8
           file =  which(name);
           system([notepad ' ' file ' &']);
        end
    end
    
