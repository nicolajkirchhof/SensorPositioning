function aoaDataReceiveFunction(aoaudp, event)
%AOADATARECEIVEFUNCTION Summary of this function goes here
%   Detailed explanation goes here
    packagequeue = get(aoaudp, 'UserData');
    data = fread( aoaudp, event.Data.DatagramLength/8, 'double' );
    
% simple format sensor_id, num_of_aoas, aoa1, score1, sourceSize1, rOpt1, ... (all double)
    id = 1; idj = 1; p = [];
    while (true)
    if idj > numel(data)
        break;
    end
        p(id,1) = data(idj);
        idj = idj+1;
        p(id,2) = data(idj);
        naoa = data(idj);
        idj = idj+1;
        p(id, 3:2+naoa*4) = data(idj:idj+naoa*4-1);
        idj = idj+naoa*4;
        id = id+1;
    end
    
    packagequeue{end+1} = p;
    set(aoaudp, 'UserData', packagequeue);
end

