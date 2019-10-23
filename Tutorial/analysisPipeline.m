%% Load dataset
%
% Load dataset from wherever it is- if it has "meanSubFullTrace" and
% "info", you're set. If it just has the LFP data (usually called
% "dataSnippits" or something like "LFPData", make sure to create the
% meanSubFullTrace by subtracting the average LFP across channels at each
% time point.

loadDir = '/Users/jscollina/Documents/MATLAB/projects/BurstTracking/';
saveDir = loadDir;
dataset = '2018-12-20_18-31-00.mat';

cd(loadDir);
%ogRecording = load(dataset);

meanSubFullTrace = ogRecording.meanSubFullTrace;
chGrid = ogRecording.info.gridIndicies;

% meanSubFullTrace = bsxfun(@minus,___,nanmean(___));

%% Test or full send?
%
% I'd recommend setting test to one first, then running the next sections
% individually. When test = 1, the smoothing is done with a large step
% size, only the first 10 seconds (~1 burst) is analyzed, and only the
% first n channels are used, where n is the number of active parallel
% clusters.

test = 0;

%% Find channels with NA and ignore them

sTest=sum(meanSubFullTrace,2);
bad = find(isnan(sTest));
chidx = setdiff(1:64,bad);
noiseChan = find(isnan(mapChGrid(zeros(size(chidx)),chGrid,chidx)));

clear sTest bad

%% Create smoothed trace by sliding window over each channel
%
% Here, you have a few choices. I would recommend running this with 700 ms
% windowSize to begin with, and, if it looks like the test is even
% reasonable, check out the file: 'determiningOptimalWindowSize.m'. That
% process will help ensure your choice of window size doesn't worsen the
% classification significantly.

tidx = 1:length(meanSubFullTrace);
stepSize = 1; %ms
windowSize = 700; %ms
chidxT = chidx;

pp = gcp;
if test == 1
    stepSize = 10;
    chidxT = chidxT(1:(2*pp.NumWorkers));
    tidx = tidx(1:10000);
end
%% Transforming meanSubFullTrace

% Currently without padding, so will lose windowSize/2 on each end of trace

smoothedFullTrace = applySmoothingFN(...
    meanSubFullTrace(chidxT,tidx),...
    stepSize,...
    windowSize...
    );

% test success:
%figure(1); imagesc(smoothedFullTrace);

%% For each channel, fit a gaussian mixture model to classify bursts and suppressions

[postBurstProb,fitInfo] = mixModel(smoothedFullTrace);

fitInfo.windowSize = windowSize;
fitInfo.stepSize = stepSize;

clear windowSize stepSize

% test success:
%figure(2); imagesc(postBurstProb)

%% Using the fit results, find points of transition from burst to suppression
[fitInfo.burstIndex,fitInfo.weirdIndex] = findBurstIndex(postBurstProb);

%%
datToCor = 1:size(postBurstProb,2); % Here, run correlation across all time points

maxLag = 1000;

corStruct = getCorStruct(...
    postBurstProb,...
    datToCor,...
    maxLag...
    );

clear idx maxLag
%%

fitInfo.chGrid = chGrid;
fitInfo.chidx = chidx;

%% Save your data

if(test==0)
    cd(saveDir);
    save(['trace_' dataset],...
        'smoothedFullTrace',...
        'postBurstProb',...
        'fitInfo',...
        'corStruct');
end


%% Functions

function [smoothedFullTrace,smoothTime] = applySmoothingFN(data,stepSize,windowSize)
smoothedFullTrace = zeros(size(data,1),size(data,2)-windowSize);
smoothStart = tic;
parfor ii = 1:size(data,1)
    msd = data(ii,:)-mean(data(ii,:));
    smoothedFullTrace(ii,:) = bsWindow(...
        msd,...
        'windowSize',windowSize,...
        'step',stepSize,...
        'padding','none',...
        'type','dev');
end
smoothTime = toc(smoothStart);
end
