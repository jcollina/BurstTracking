function interactivePlot(traceToPlot,chidx,chGrid)

%weirdos = find(isoutlier(std(traceToPlot,[],2)));

ct = 1;
sys1 = addLine(traceToPlot,ct);
sys2 = mapChGrid(traceToPlot(:,ct),chGrid,chidx);

noiseChan = find(isnan(sys2));
a = get(0,'Screensize');
a(3) = a(3)/(1.5);
f = figure('Name','Interactive Burst','Position', a);

subplot(4,3,[3,6,9,12])
h1 = imagesc(sys1);
set(gca,'clim',[0,1]);
ax = gca;
cl = ax.CLim;

subplot(4,3,[1:2,4:5,7:8,10:11])
h2 = imagesc(sys2);
hold on
for ii = 1:length(noiseChan)
[x,y] = ind2sub(size(chGrid),noiseChan(ii));
rectangle('Position',[y-.5,x-.5,1,1],'FaceColor','k')
end
set(gca,'clim',cl);
%{
for ii = 1:length(weirdos)
[x,y] = ind2sub(size(gr),find((gr)==chidx(weirdos(ii))));
patch([y-.1 y-.5 y-.5 y],[x-.5 x-.1 x x-.5 ],'k','FaceAlpha',.4);
patch([y-.1 y+.5 y+.5 y],[x+.5 x-.1 x x+.5 ],'k','FaceAlpha',.4);
end
%}


b1 = uicontrol('Parent',f,'Style','slider','Position',[a(1)+0.05*a(3),a(2)+0.05*a(4),a(3)-2*(a(1)+0.05*a(3)),0.01*a(4)],...
    'value',ct, 'min',1,'max',size(traceToPlot,2));
b1.Callback = @(es, ed) {
    set(h2, 'CData', mapChGrid(traceToPlot(:,ceil(es.Value)),chGrid,chidx));
    set(h1, 'CData', addLine(traceToPlot,ceil(es.Value)));
    };
%%
clear traceToPlot;    
%%
end

function tracePrL = addLine(tracePrL,pt)

col = 1 - mean(tracePrL(:,pt));

shadesF = [repmat(col,[1,8])];
shadesB = fliplr(shadesF);

distBack = pt - 1;
distForward = size(tracePrL,2) - pt;

tracePrL(:,pt) = col;

if distBack > 0
    fillB = shadesB(1:min(distBack,length(shadesB)));
tracePrL(:,((pt-length(fillB)):(pt-1))) = repmat(fillB,[size(tracePrL,1),1]);
end

if distForward > 0
fillF = shadesF(1:min(distForward,length(shadesF)));
tracePrL(:,((pt+1):(pt+length(fillF)))) = repmat(fillF,[size(tracePrL,1),1]);
end

%tracePrL = tracePrL(:,s:b);
end