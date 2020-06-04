%% read c3d data, save as trc and run inverse kinematics
% This code is compatible with OpenSim 4.1 and it is not tested on earlier
% versions. To run this coed, please upgrade your model file to OpenSim 4.1.
% To run this code you need to:
% (1) Know where your IKSetup.xml, model (.osim) and C3D files are because
% the code prompts you to select them in order to retrieve the file names
% and paths. I suggest creating a folder consisting the IKsetup.xml and the
% OpenSim model in the same directory as this script for ease of access.
% (2) Have two functions called 'runIK.m' and 'write_trc_file.m'
% Code rewritten by Rosti Readioff, June 2020
clear all
clc
%% Prompting user to select the files required for this analysis
% Prompt user to pick the C3D file to retrieve file name & path
[c3dFileName, c3dFilePath]=uigetfile('*.c3d','Pick the marker file.');
filename=fullfile(c3dFilePath, c3dFileName);

% convert c3d file to trc file (input to Opensim)
write_trc_file(filename);

% Prompt user to pick .osim (model) to retrieve file name & path
[ModelName, ModelPath] = uigetfile('*.osim','Pick the model file.');
ModelNamePath=fullfile(ModelPath, ModelName);

% Prompt user to pick IKSetup.xml file to retrieve file name & path
[IKSetupName, IKSetupPath] = uigetfile('*.xml','Pick the IKSetup file.');
IKSetupNamePath=fullfile(IKSetupPath, IKSetupName);

%Replace extension of the .c3d to .trc
IKinput_filename = strrep(filename,'.c3d','.trc');

%% Run inverse kinematics first on regular model with no translation
noTranslation=[0,0,0]; % zero translations [dx,dy,dz] vector specifying
% by how much to translate the glenohumeral joint centre.
runIK(IKinput_filename,noTranslation,ModelNamePath,IKSetupNamePath);

%% Now specify required GH joint translation (in m in the scapula frame)
GHchanges = [-0.02 -0.01 0.01 0.02];

for i=1:length(GHchanges)
    % apply this to the x direction
    change = [GHchanges(i) 0 0];
    runIK(IKinput_filename,change,ModelNamePath,IKSetupNamePath);
    % the y direction
    change = [0 GHchanges(i) 0];
    runIK(IKinput_filename,change,ModelNamePath,IKSetupNamePath);
    % and the z direction
    change = [0 0 GHchanges(i)];
    runIK(IKinput_filename,change,ModelNamePath,IKSetupNamePath);
end

%% Move the result files to a new folder called 'IK output'
IKResultsPath=c3dFilePath;
resultsfolder = 'IK output';
mkdir(fullfile(IKResultsPath,resultsfolder));
    
% move .sto file to the results folder
[status, message] = movefile('*.sto', [IKResultsPath '\' resultsfolder]);
if(status ~= 1)
    disp(['Setup file FAILED at relocating because ' message]);
end

% move .xml file to the results folder
[status, message] = movefile('*.xml', [IKResultsPath '\' resultsfolder]);
if(status ~= 1)
    disp(['Setup file FAILED at relocating because ' message]);
end

% move .trc file to the results folder
[status, message] = movefile([IKResultsPath,'*.trc'], [IKResultsPath '\' resultsfolder]);
if(status ~= 1)
    disp(['Setup file FAILED at relocating because ' message]);
end  

% move .mot file to the results folder
[status, message] = movefile([IKResultsPath,'*.mot'], [IKResultsPath '\' resultsfolder]);
if(status ~= 1)
    disp(['Setup file FAILED at relocating because ' message]);
end  

