function  timestamps = timestampRecorder( input )
%%
% debug = @(x) x;
debug = @(x) disp(x);
tts = @(x) x;




labBarrier;

% init_data = gatherInitData(livedatacollection, 60);



labBroadcast(1, true);

% function init_data = gatherInitData(livedatacollection, length)
% nowTime = @() rem(now,1)*1e5;
% update_step_s = 2;
% start_time = nowTime();
% update_time = rem(now,1)*1e5+update_step_s;
% end_time = start_time+length;
% cnt = 1;
% data = {};
% while nowTime() < end_time
%     data{cnt,1} = livedatacollection.Data();
%     if nowTime() > update_time
%         disp(num2str(end_time - (rem(now,1)*1e5)));
%         update_time = nowTime() + update_step_s;
%     end
%     cnt = cnt+1;
% end
% init_data = data;


