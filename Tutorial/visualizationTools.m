%% Visualization Tools
%load trace_2018-12-20_18-31-00.mat;

burstNumber = 7;
traceToPlot = postBurstProb(:,fitInfo.burstIndex(burstNumber,1):fitInfo.burstIndex(burstNumber,2));

%% Interactive Burst Plot
%
% For a single burst, you can click through frames to watch how the burst
% spreads across the cortex.

interactivePlot(traceToPlot,fitInfo.chidx,fitInfo.chGrid)

%% Movie of Burst Plot
%
% For a single burst, you can create a movie (which will be saved
% automatically under the name of your choice) to watch how the burst
% spreads across the cortex.

name = 'Test';
frameRate = 5; 
movieFrames = burstMovie(name,frameRate,traceToPlot,fitInfo.chidx,fitInfo.chGrid);

%% Using lagVector.m -->
%
% Input a #Channel x #Channel lag matrix, along with the channel grid
% mapping and "good channel index", to get what is essentially an average
% direction of burst propagation across each channel. 

vectorStruct = lagVector(corStruct.lagMat,fitInfo.chidx,fitInfo.chGrid);
figure;
quiver(...
    vectorStruct.loc(1,:),...
    vectorStruct.loc(2,:),...
    vectorStruct.vector(1,:),...
    vectorStruct.vector(2,:));
