function interactivePlot(s,b,chidx,traceToPlot,gr)

weirdos = find(isoutlier(std(traceToPlot,[],2)));

ct = s;
sys1 = addLine(traceToPlot,ct,s,b);
sys2 = mapChGrid(traceToPlot(:,ct),gr,chidx);

noiseChan = find(isnan(sys2));
a = get(0,'Screensize');
a(3) = a(3)/(1.5);
f = figure('Name','Interactive Burst','Position', a);

subplot(4,3,[3,6,9,12])
h1 = imagesc(sys1);
set(gca,'clim',[0,1]);

subplot(4,3,[1:2,4:5,7:8,10:11])
h2 = imagesc(sys2);
hold on
for ii = 1:length(noiseChan)
[x,y] = ind2sub(size(gr),noiseChan(ii));

rectangle('Position',[y-.5,x-.5,1,1],'FaceColor','k')
end

for ii = 1:length(weirdos)
[x,y] = ind2sub(size(gr),find((gr)==chidx(weirdos(ii))));
patch([y-.1 y-.5 y-.5 y],[x-.5 x-.1 x x-.5 ],'k','FaceAlpha',.4);
patch([y-.1 y+.5 y+.5 y],[x+.5 x-.1 x x+.5 ],'k','FaceAlpha',.4);
end

set(gca,'clim',[0,1]);

b1 = uicontrol('Parent',f,'Style','slider','Position',[a(1)+0.05*a(3),a(2)+0.05*a(4),a(3)-2*(a(1)+0.05*a(3)),0.01*a(4)],...
    'value',ct, 'min',s,'max',b);
b1.Callback = @(es, ed) {
    set(h2, 'CData', mapChGrid(traceToPlot(:,ceil(es.Value)),gr,chidx));
    set(h1, 'CData', addLine(traceToPlot,ceil(es.Value),s,b));
    };
%%
clear traceToPlot;    
%%
end
function tracePrL = addLine(tracePrL,pt,s,b)
tracePrL(:,(pt:pt+1)) = 10;
tracePrL(:,[pt-1,pt+2]) = -10;
tracePrL = tracePrL(:,s:b);
end