function [ pc ] = enable( pc, type )
%ENABLE Summary of this function goes here
%   Detailed explanation goes here
    if ~pc.model.(type).enable
        write_log('Enabling %s model', type);
        pc.model.(type).enable = true;
    else
        write_log('%s Model aready added', type);
    end

end

