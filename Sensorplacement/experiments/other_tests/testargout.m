function out = testargout()
    if nargout > 0
        out = 42;
    else
        disp('test');
    end