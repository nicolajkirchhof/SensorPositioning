function [ pc ] = disable( pc, type )
%ENABLE Summary of this function goes here
%   Detailed explanation goes here
    if pc.model.(type).enable
        write_log('Disabling %s model', type);
        pc.model.(type).enable = false;
    else
        write_log('%s model aready disabled', type);
    end

end

