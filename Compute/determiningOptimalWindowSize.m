windowSizes = 500:100:2000;
tIdx = 1:240000; %4 minutes
sizeEffect = zeros(length(chidx),length(windowSizes));

%clust_dist = zeros(1,length(windowSizes));
%bhatt_dist = zeros(1,length(windowSizes));

iter = zeros(length(chidx),length(windowSizes));

tic
k = 2;
maxIter = 1000;
stepSize = 1;

for ii = 1:length(chidx)
    msd = meanSubFullTrace(chidx(ii),tIdx);
    msd = msd - mean(msd);
    
    for jj = 1:length(windowSizes)
        data = bsWindow(...
            msd,...
            'windowSize',windowSizes(jj),...
            'step',stepSize,...
            'padding','none',...
            'type','power');
        
        data = data(data~=0);
        data = data(randi(length(data),ceil(length(data)/10),1));
        X = log10(data)';
        
            [ ~ , f] = mixModel(X);
            sizeEffect(ii,jj) = f.dPrime;
            iter(ii,jj) = f.numIter;
        
        %{
    subplot(vertG,horzG,i)
    histogram(X,'Normalization','pdf')
    title(['WindowSize: ' num2str(windowSize(i))])
    if (rem(i,horzG)==1 && ceil(i/horzG)==vertG)
        xlabel('log(smoothed absolute mean)')
        ylabel('Normalized Count')
    end
        %}
    end
    
    %optimalWindow = windowSize((bd_ch19==max(bd_ch19)));
    
    %r = bhatt_dist;
    %minOpt = windowSizes(find(~isoutlier(r),1));
end
toc
%%
figure;
plot(windowSizes,sizeEffect','-k','Linewidth',.01)
hold on
plot(windowSizes,median(sizeEffect),'-r','Linewidth',5)

%%
windowDistances = vertcat(windowSize,bd_ch1,bd_ch6,bd_ch19,bd_ch22);
plot(windowDistances(1,:),windowDistances(2:5,:),':o')
xlabel('Window Size (ms)')
ylabel('Seperability (Bhatta. Dist.)')
title('Optimal Window Size for Classifying Bursts')
legend('Ch. 3','Ch. 8','Ch. 31','Location','southeast')
