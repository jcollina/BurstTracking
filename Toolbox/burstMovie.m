function F = burstMovie(name,s,b,chidx,traceToPlot,gr)

v = VideoWriter(name,'MPEG-4');
v.FrameRate = 5;
%v.FileFormat = 'mp4';
open(v);

timeSpan = b - s;%b(gIdx(i))-s(gIdx(i));

ct = s;
%weirdos = find(isoutlier(std(traceToPlot,[],2)));
noiseChan = find(isnan(mapChGrid(traceToPlot(:,ct),gr,chidx)));

f = figure('Name','Frame Recordings','Position', get(0,'Screensize')./[1 1 2.2 1]);
set(gca,'Color','none')
set(gcf,'Color','none')
%f.InnerPosition = f.InnerPosition + [0 -.5 0 0];
s = subplot(1,1,1);
s.Position = s.Position + [0 -.05 0 0];
H1 = imagesc(mapChGrid(traceToPlot(:,ct),gr,chidx));
set(gca,'clim',[0 1]);

%colorbar('Ticks',[0.1, 0.9],...
%         'TickLabels',{'Suppression','Burst'})

hold on
for ii = 1:length(noiseChan)
    [x,y] = ind2sub(size(gr),noiseChan(ii));   
    rectangle('Position',[y-.5,x-.5,1,1],'FaceColor',[.25 .25 .25],'EdgeColor','None')
end
rectangle('Position',[3-.5,11-.5,2,1],'FaceColor','w','EdgeColor','None')
%for ii = 1:length(weirdos)
%    [x,y] = ind2sub(size(gr),find((gr)==chidx(weirdos(ii))));
%    patch([y-.1 y-.5 y-.5 y],[x-.5 x-.1 x x-.5 ],'k','FaceAlpha',.4);
%    patch([y-.1 y+.5 y+.5 y],[x+.5 x-.1 x x+.5 ],'k','FaceAlpha',.4);
%end

txt = ['\Deltat: ',num2str(0),' ms'];
an = annotation('textbox',[.10 .9 .85 .1],'String',txt,'EdgeColor','none',...
    'HorizontalAlignment','center');
an.FontSize = 50;

axis tight manual
ax = gca;
ax.NextPlot = 'replaceChildren';
set(gcf,'color','w');
F(timeSpan) = struct('cdata',[],'colormap',[]);
for j = 1:(timeSpan-1)
    H1.CData = mapChGrid(traceToPlot(:,ct + j),gr,chidx);
    an.String = ['Time: ',num2str(j),' ms'];
    F(j) = getframe(gcf);
    writeVideo(v,F(j))
end
close(v);
%%
end
