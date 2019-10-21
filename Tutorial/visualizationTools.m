%% Visualization Tools
load trace_2018-12-20_18-31-00.mat;

burstNumber = 7;
traceToPlot = postBurstProb(:,fitInfo.burstIndex(burstNumber,:));

%% Interactive Burst Plot
interactivePlot(traceToPlot,chidx,chGrid)

%% Movie of Burst Plot
name = 'Test';
movieFrames = burstMovie(name,traceToPlot,chidx,chGrid);

%% From lagVector.m -->
figure;
quiver(...
    vectorStruct.location(1,:),...
    vectorStruct.location(2,:),...
    vectorStruct.vector(1,:),...
    vectorStruct.vector(2,:));
