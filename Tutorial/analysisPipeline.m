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
ogRecording = load(dataset);

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
%%
[smoothedFullTrace,smoothTime] = applySmoothingFN(...
    meanSubFullTrace(chidxT,tidx),...
    stepSize,...
    windowSize...
    );
% test success:
figure; imagesc(smoothedFullTrace);

%% For each channel, fit a gaussian mixture model to classify bursts and suppressions

% Full dataset will take between 15 and 30 minutes- 15 if the
% classification runs well, and 30+ if every fit maxes out. That's why you
% should make sure to run this after test = 1 first.

% Parameters for mixture model:
%
% k:        How many clusters do you expect? Right now the code is only set up for
%           two clusters.
% maxIter:  How many fitting iterations before the function gives up?
% minDist:  Minimum clustering distance (sometimes the function
%           accidentally captures the same gaussian twice)
%
k = 2;
maxIter = 1000;
minDist = 0.5;

fitInfo = applyFittingFN(...
    smoothedFullTrace,...
    k,...
    maxIter,...
    minDist...
    );

fitInfo.windowSize = windowSize;
fitInfo.stepSize = stepSize;
clear windowSize stepSize k maxIter minDist
% test success:
figure; imagesc(fitInfo.burstProb)

%% Using the fit results, find points of transition from burst to suppression
[b,s] = findBurstIndex(...
    fitInfo.burstProb...
    );

fitInfo.bIndex = b;
fitInfo.sIndex = s;

clear b s
%%
idx = 1:size(fitInfo.burstProb,2);

maxLag = 100;
corStruct = getCorStruct(...
    pr_b800,...
    idx,...
    maxLag...
    );

clear idx maxLag
%%
%% Save your data

if(test==0)
    cd(saveDir);
    save(['trace_' dataset],...
        'smoothedFullTrace',...
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
%%

function fitInfo = applyFittingFN(smoothedData,k,maxIter,minDist)
numChan = size(smoothedData,1);
r = zeros(1,numChan);
bd = zeros(1,numChan);
maxed = zeros(1,numChan);
m = zeros(2,numChan);
sd = zeros(2,numChan);
burstProb = 1.1 + zeros(size(smoothedData));
suppProb = burstProb;
fitStart = tic;
parfor i = 1:numChan
    dataTemp = smoothedData(i,:);
    zidx = find(dataTemp);
    lend = length(dataTemp);
    dataTemp = dataTemp(dataTemp ~= 0);
    X = log10(dataTemp)';
    r(i) = 0;
    while r(i) < minDist
        [mt,st,~,~,prt_t,r(i),bd(i),maxed(i)] = mixModel1D(X,k,maxIter);
    end
    prt = zeros(lend,2) + 0.5;
    prt(zidx,:) = prt_t;
    if mt(1) < mt(2)
        idx = [1 2];
        suppProb(i,:) = prt(:,1)';
        burstProb(i,:) = prt(:,2)';
    else
        idx = [2 1];
        suppProb(i,:) = prt(:,2)';
        burstProb(i,:) = prt(:,1)';
    end
    m(:,i) = mt(idx);
    sd(:,i) = st(idx);
end
fitTime = toc(fitStart);
fitInfo = struct(...
    'burstProb', burstProb, ...
    'suppProb', suppProb, ...
    'mu', m, ...
    'std', sd, ...
    'regDist', r, ...
    'bhattDist', bd, ...
    'iterNum', maxed, ...
    'k', k, ...
    'maxIter', maxIter, ...
    'minDist', minDist, ...
    'fitTime', fitTime ...
    );
end

