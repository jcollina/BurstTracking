function velocityStruct = velocityEstimation(data,gr,chidx,s,b)

distMat = zeros(length(chidx));

for i = 1:53
    [tempx,tempy] = ind2sub(size(gr),find(gr==chidx(i)));
    for j = 1:53
        [tempx2,tempy2] = ind2sub(size(gr),find(gr==chidx(j)));
        d = pdist([tempx tempy ; tempx2 tempy2],'euclidean');
        distMat(i,j) = d;
    end
end

order = zeros(length(s),length(chidx));
times = zeros(length(s),length(chidx));
dists = zeros(length(s),length(chidx));

for bidx = 1:length(s)
    
tidx = s(bidx):b(bidx);
tempb = data(:,tidx);
idx = find(tempb > 0.5);
tempbt = zeros(size(tempb));
tempbt(idx) = 1;

result = arrayfun(@(ROWIDX) find(tempbt(ROWIDX,:),1), (1:size(tempbt,1)).','UniformOutput',false);
result(cellfun(@isempty,result)) = {1000000};

onsets = [cell2mat(result) [1:length(result)]'];

temp = sortrows(onsets,1);
onsetIndex = sortrows([temp (1:size(resM,1))'],2);

onsetIndex(:,1) = onsetIndex(:,1) - min(onsetIndex(:,1));
first_ch = find(onsetIndex(:,1)==0 , 1);

times(bidx,:) = onsetIndex(:,1);
dists(bidx,:) = distMat(first_ch,onsetIndex(:,2));
order(bidx,:) = onsetIndex(:,3);
end

orderedTimes = sort(times,2);
wIdx = find(isoutlier(orderedTimes(:,4)));
gIdx = setdiff(1:length(orderedTimes(:,4)),wIdx);

dists(dists==0) = NaN;
times(times>5000) = NaN;

velocityStruct = struct(...
    'times', times, ...
    'order', order, ...
    'dists', dists, ...
    'wIdx', wIdx, ...
    'gIdx', gIdx, ...
    'distMat', distMat ...
    );

end