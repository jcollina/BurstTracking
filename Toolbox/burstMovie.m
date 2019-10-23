function F = burstMovie(name,frameRate,traceToPlot,chidx,chGrid)

warning('off','MATLAB:audiovideo:VideoWriter:mp4FramePadded');

v = VideoWriter(name,'MPEG-4');
v.FrameRate = frameRate;
open(v);
timeSpan = size(traceToPlot,2);
noiseChan = find(isnan(mapChGrid(traceToPlot(:,1),chGrid,chidx)));

f = figure('Name','Frame Recordings','Position', get(0,'Screensize')./[1 1 2.2 1]);
f.Visible = 'off';
set(gca,'Color','none')
set(gcf,'Color','none')
sF = subplot(1,1,1);
sF.Position = sF.Position + [0 -.05 0 0];
H1 = imagesc(mapChGrid(traceToPlot(:,1),chGrid,chidx));
set(gca,'clim',[0 1]);

%colorbar('Ticks',[0.1, 0.9],...
%         'TickLabels',{'Suppression','Burst'})

hold on
for ii = 1:length(noiseChan)
    [x,y] = ind2sub(size(chGrid),noiseChan(ii));   
    rectangle('Position',[y-.5,x-.5,1,1],'FaceColor',[.25 .25 .25],'EdgeColor','None')
end
rectangle('Position',[3-.5,11-.5,2,1],'FaceColor','w','EdgeColor','None')

txt = ['\Deltat: ',num2str(0),' ms'];
an = annotation('textbox',[.10 .9 .85 .1],'String',txt,'EdgeColor','none',...
    'HorizontalAlignment','center');
an.FontSize = 50;

axis tight manual
ax = gca;
ax.NextPlot = 'replaceChildren';
set(gcf,'color','w');

F(timeSpan) = struct('cdata',[],'colormap',[]);

tic;
for j = 1:timeSpan
   
    H1.CData = mapChGrid(traceToPlot(:,j),chGrid,chidx);
    an.String = ['Time: ',num2str(j),' ms'];
    orig_mode = get(f, 'PaperPositionMode');
    set(f, 'PaperPositionMode', 'auto');
    cdata = print(f,'-RGBImage');
    set(f, 'PaperPositionMode', orig_mode);
    F(j) = im2frame(cdata);
    writeVideo(v,F(j));
%{
    if j == 1        
        t = toc;
        fprintf('The movie should take ~%0.1d seconds to create.',t*timeSpan)
    end   
    %}
    progressbarText((j-1)/(timeSpan-1));
end
close(v);
end
