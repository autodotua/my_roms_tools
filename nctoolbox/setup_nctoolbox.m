function setup_nctoolbox

home = fileparts(which(mfilename));
addpath(fullfile(home, 'java'));
addpath(fullfile(home, 'cdm'));

% Added so that we can swap out utitlies modules for different user groups, 
% like sura shelf_hypoxia
addpath(genpath(fullfile(home, 'cdm', 'utilities'))); 

warning off
try 
    setup_nctoolbox_java;
catch me
    ex = MException('MBARI:NCTOOLBOX', 'Failed to setup the Java classpath');
    ex.throw
end
warning on
