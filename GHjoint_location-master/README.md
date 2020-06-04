# GHjoint_location
Analysis of the effect of the location of the GH joint on shoulder modelling
 
This uses the [upper extremity model of Saul and Murray](http://simtk.org/projects/upexdyn) (renamed as MoBL_ARMS.osim and saved in Opensim 4.1 format).
 
It also uses Opensim 4.1 and the Matlab API, which can be set up by running configureOpenSim.m (see details [here](https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab)).

The main code to run is read_data_run_IK.m, where the code prompts you to select the relevant c3d file, the IK setup and the upper limb model.
This script then:
1. calls write_trc_file.m to take the marker data from the c3d file, rename them to match the Saul & Murray model, and save them in a trc file (input to OpenSim IK)
2. performs an IK without changes to the glenohumeral joint centre, then sets different locations of the glenohumeral joint centre to be analysed through IK in a loop.
3. runIK.m function performs the inverse kinematic analysis
4. Creates a new subfolder where all output files, including .mot, .sto, and .xml files.

This will allow us to see the effect of the location of the glenohumeral joint centre on the shoulder angles.


Rosti Readioff, June 2020