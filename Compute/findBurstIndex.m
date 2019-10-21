function [burstIndex, weirdos] = findBurstIndex(prb)
%% Find Burst Indices

stds = std(prb,[],2);
weirdos = find(isoutlier(stds))';
goods = setdiff(1:length(stds),weirdos);
prb_g = prb(goods,:);

mprb = mean(prb);
mprb_g = mean(prb_g);

fullB = find(mprb>.99);
fullS = find(mprb<.01);

rmprb_g = round(mprb_g);
shiftForward = [0 rmprb_g(1:(end-1))];

pts = find((shiftForward - rmprb_g) == -1 );

s = [];
b = [];

i = 1;
while 1
    
    temp = pts(i);
    
    stemp = max(fullS(fullS<temp));
    btemp = min(fullB(fullB>temp));
        
    if (btemp - stemp) < 2000
    s = [s stemp];
    b = [b btemp];
    end
        
i = i + 1;
if i > length(pts)
    break
end
end

burstIndex = [s' b'];

%{
indexStruct = struct(...
    's',s,...
    'b',b,...
    'weirdos',weirdos...
    );
%}
end
