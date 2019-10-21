% BurstTrackingLocalHookTemplate
%

% Modified by JSC from code written by DHB, 10/23/18

%% Define project
projectName = 'BurstTracking';

%% Clear out old preferences
if (ispref(projectName))
    rmpref(projectName);
end

%% Specify project location
projectBaseDir = tbLocateProject(projectName);

% Get path to data in project code with getpref('ISETTwoLine','dataDir');
% setpref(projectName,'dataDir',fullfile(baseDir,'IBIO_Analysis',projectName));




