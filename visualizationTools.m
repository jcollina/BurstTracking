%% Visualization Tools

%% Interactive Burst Plot
interactivePlot(...
    indexStruct.s(burstIdx),...
    indexStruct.b(burstIdx),...
    chidx,...
    fitInfo.burstProb,...
    info.gridIndicies);

%% Movie of Burst Plot
movieFrames = burstMovie(...
    indexStruct.s(burstIdx),...
    indexStruct.b(burstIdx),...
    chidx,...
    fitInfo.burstProb,...
    info.gridIndicies);

%% From lagVector.m -->
figure;
quiver(...
    vectorStruct.location(1,:),...
    vectorStruct.location(2,:),...
    vectorStruct.vector(1,:),...
    vectorStruct.vector(2,:));

%% From 