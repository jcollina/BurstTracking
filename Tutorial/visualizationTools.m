%% Visualization Tools
%load trace_2018-12-20_18-31-00.mat;

burstNumber = 7;
traceToPlot = postBurstProb(:,fitInfo.burstIndex(burstNumber,1):fitInfo.burstIndex(burstNumber,2));

%% Interactive Burst Plot
interactivePlot(traceToPlot,chidx,chGrid)

%% Movie of Burst Plot
name = 'Test';
movieFrames = burstMovie(name,traceToPlot,chidx,chGrid);

%% From lagVector.m -->
figure;
quiver(...
    vectorStruct.loc(1,:),...
    vectorStruct.loc(2,:),...
    vectorStruct.vector(1,:),...
    vectorStruct.vector(2,:));
