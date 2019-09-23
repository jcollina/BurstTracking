function gridTempAct = mapChGrid(chanAct,gridIndicies,chidx)

gridTempAct = NaN(size(gridIndicies));

for i = 1:length(chanAct)
    gridTempAct(gridIndicies == chidx(i)) = chanAct(i); 
end
%{
minv = min(min((gridTempAct)));
maxv = max(max((gridTempAct)));
toPlot = gridTempAct;
toPlot(isnan(toPlot)) = minv-((maxv-minv)/5);
ddd=[0 0 0;jet(10)];
colormap(ddd);
figure; imagesc(toPlot)
%}
end


