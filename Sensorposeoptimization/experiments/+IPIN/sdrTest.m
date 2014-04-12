function sdrTest( input )
%SDRTEST Summary of this function goes here
%   Detailed explanation goes here
labBarrier;
idx_sdr = 1;
disp('barrier');
for j = 1:3
labSend(1, idx_sdr, 1);
disp(['send' num2str(j)]);
for i = 1:100
    received_data{i} = labReceive(idx_sdr);
    disp(i);
end

labSend(0, idx_sdr, 1);
end
labSend(0, idx_sdr, 3);

end

