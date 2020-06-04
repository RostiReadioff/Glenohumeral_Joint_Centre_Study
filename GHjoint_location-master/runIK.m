function runIK(filename,GH_translation,ModelNamePath,IKSetupNamePath)

% Runs inverse kinematics on the marker data in filename and saves the
% results in the same directory
% GH_translation is an optional input: it is a [dx,dy,dz] vector specifying
% by how much to translate the glenohumeral joint centre (expressed in m in the
% scapula frame)
%
% Dimitra Blana, February 2020
% Modified by Rosti Readioff, June 2020 making it accessible for users to
% easily apply the current script on any .osim and .xml files. 

[path,name,~] = fileparts(filename);


%% Load OpenSim libs
import org.opensim.modeling.*

% specify generic IK setup file
% IKSetupNamePath is name and path of the IKSetup.xml file, this is defined
% by prompting the user in read_data_run_IK.m file.
ikTool = InverseKinematicsTool(IKSetupNamePath);

% Load the model and initialize
% ModelNamePath is name and path of the model (.osim) file, this is defined
% by prompting the user in read_data_run_IK.m file.
model=Model(ModelNamePath);

% only do this is GH joint translation is required
if nargin>1
    % get the location of GH in the scapula grame
    GH_trans_frame = model.getJointSet().get('unrothum').get_frames(0);
    normal_trans = GH_trans_frame.get_translation;
    % convert from Opensim Vec3 format to Matlab vector format, to add
    % required translation to normal distance
    normal_trans_vec = [normal_trans.get(0) normal_trans.get(1) normal_trans.get(2)];
    new_GH_trans_vec = normal_trans_vec + GH_translation;
    new_GH_trans = Vec3(new_GH_trans_vec(1),new_GH_trans_vec(2),new_GH_trans_vec(3));
    GH_trans_frame.set_translation(new_GH_trans);
    % also add the GH translation to the output file name
    namefix = ['x' num2str(GH_translation(1)) 'y' num2str(GH_translation(2)) 'z' num2str(GH_translation(3))];
    name = [name namefix];
end

model.initSystem();

% Tell Tool to use the loaded model
ikTool.setModel(model);

% Get trc data to determine time range
markerData = MarkerData(filename);

% Get initial and intial time 
initial_time = markerData.getStartFrameTime();
final_time = markerData.getLastFrameTime();

% Setup the ikTool for this trial
ikTool.setName(name);
ikTool.setMarkerDataFileName(filename);
ikTool.setStartTime(initial_time);
ikTool.setEndTime(final_time);
ikTool.setOutputMotionFileName(fullfile(path,[name '.mot']));

% Save the settings in a setup file
outfile = ['SetupIK_' name '.xml'];
ikTool.print(outfile);

fprintf(['Performing IK on file ' name '\n']);
% Run IK
ikTool.run();


