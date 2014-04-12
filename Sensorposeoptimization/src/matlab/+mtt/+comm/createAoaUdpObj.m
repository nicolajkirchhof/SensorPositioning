function [ aoaudp ] = getAoaUdpObj(rhost, rport, lport)
%GETAOAUDPOBJ Summary of this function goes here
%   Detailed explanation goes here

%check input arguments
if nargin < 1
    rhost = '127.0.0.1';
end
if nargin < 2
    rport = 20000;
end

if nargin < 3
    lport = 20001;
end
packagequeue = {};

aoaudp = udp(rhost, rport, 'LocalPort', lport, 'Name', 'IrIpClient',...
    'Timeout', 5000, 'DatagramTerminateMode', 'off', 'InputBufferSize', 4096,...
    'OutputBufferSize', 1024,'ByteOrder', 'littleEndian',...
    'DatagramReceivedFcn', @aoaDataReceiveFunction );
set(aoaudp, 'UserData', packagequeue);
fopen(aoaudp);

end

