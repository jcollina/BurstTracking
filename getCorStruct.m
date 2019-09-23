function corStruct = getCorStruct(prb,idx,maxLag)
corStart = tic;
lagMat = zeros(size(prb,1));
corMat = zeros(size(prb,1));
c = 0;
for ii = 1:size(prb,1)
    for jj = (1+c):size(prb,1)
        [crossCor,lag] = xcorr(prb(ii,idx),prb(jj,idx),maxLag);
        lagMat(ii,jj) = lag(crossCor==max(crossCor));
        corMat(ii,jj) = max(crossCor);
    end
    c = c + 1;
end
lagMat = lagMat + (-1*lagMat');
corMat = corMat + corMat';
corTime = toc(corStart);
corStruct = struct;
corStruct.corMat = corMat;
corStruct.lagMat = lagMat;
corStruct.corTime = corTime;
end