function write_trc_file(filename)
% write_trc_file creates a .trc file that can be used as input to the
% MoBL_ARMS upper limb model
%
% Input
%     filename = the complete path and name of the .c3d file that we want
%                to analyze. The output .trc file has the same path and name.
%
% Dimitra Blana, February 2020
% Based on c3dExport.m by James Dunne and build_trc_file.m by Dimitra Blana


[path,name,~] = fileparts(filename);

%% Load OpenSim libs
import org.opensim.modeling.*

%% Construct an opensimC3D object with input c3d path
% Constructor takes full path to c3d file and an integer for forceplate
% representation (1 = COP). 
c3d = osimC3D(filename,1);
TRC_filename = fullfile(path,[name '.trc']);

%% Get the c3d as Matlab Structure
[data, ~] = c3d.getAsStructs();

time = data.time;
nframe = 1:length(time);
framerate = 1/(time(2)-time(1));
startFrame = 1;

%% Get the names of the markers we want from experimental data and the model

markers = {'C7';'CLAV';'RSHO';'RELB';'RWRA';'RWRB'};
marker_names = {'C7';'R.Clavicle';'R.Shoulder';'R.Elbow.Lateral';'R.Radius';'R.Ulna'};

%% Build trc file
% first initialise the header with a column for the Frame # and the Time
% also initialise the format for the columns of data to be written to file
dataheader1 = 'Frame#\tTime\t';
dataheader2 = '\t\t';
format_text = '%i\t%2.4f\t';
% initialise the matrix that contains the data as a frame number and time row
data_out = [nframe; time'];

% Get initial position of CLAV to translate all data so that at the initial
% frame, CLAV = (0,0,0)
CLAV_init = data.CLAV(1,:);
CLAV_init_mat = repmat(CLAV_init,length(time),1);

for imark = 1:length(markers)

    % now loop through each maker name and make marker name with 3 tabs for the
    % first line and the X Y Z columns with the marker numnber on the second
    % line all separated by tab delimeters
    dataheader1 = [dataheader1 marker_names{imark} '\t\t\t'];
    dataheader2 = [dataheader2 'X' num2str(imark) '\t' 'Y' num2str(imark) '\t'...
        'Z' num2str(imark) '\t'];
    format_text = [format_text '%f\t%f\t%f\t'];

    if (isfield(data,markers{imark}))
        % get the input data
        XYZ = data.(markers{imark}) - CLAV_init_mat;
        % add 3 rows of data for the X Y Z coordinates of the current marker
        % Vicon coordinate frame is x right, y front, z up. Convert to x
        % front, y up, z right for OpenSim model
        data_out = [data_out; XYZ(:,2)'/1000; XYZ(:,3)'/1000; XYZ(:,1)'/1000];

    else
        error(['Invalid marker name ', markers{imark}]);
    end
end

dataheader1 = [dataheader1 '\n'];
dataheader2 = [dataheader2 '\n'];
format_text = [format_text '\n'];

%open the file
fid_1 = fopen(TRC_filename,'w');

% first write the header data
fprintf(fid_1,'PathFileType\t4\t(X/Y/Z)\t %s\n',[name '.trc']);
fprintf(fid_1,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
fprintf(fid_1,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n', framerate, framerate, length(time), length(markers), 'm', framerate, startFrame, length(time));
fprintf(fid_1, dataheader1);
fprintf(fid_1, dataheader2);

% then write the output marker data
fprintf(fid_1, format_text,data_out);

% close the file
fclose(fid_1);

disp(['Written trc file ' TRC_filename]);