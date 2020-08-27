subjects = [1:7 9:20];

compute_0_AMICA_investigation_settings

% raw data is on a different server
input_path = 'V:\spot_rotation\raw_EEG_data';
chanloc_path = 'V:\spot_rotation\raw_EEG_data';


% preprocessing
channel_locations_filename = 'channel_locations.elc';
channels_to_remove = {'N29' 'N30' 'N31'};
eog_channels  = {'G16' 'G32'};
resample_freq = 250;

if ~exist('ALLEEG','var'); eeglab; end
pop_editoptions( 'option_storedisk', 0, 'option_savetwofiles', 1, 'option_saveversion6', 0, 'option_single', 0, 'option_memmapdata', 0, 'option_eegobject', 0, 'option_computeica', 1, 'option_scaleicarms', 1, 'option_rememberfolder', 1, 'option_donotusetoolboxes', 0, 'option_checkversion', 1, 'option_chat', 1);


filenames = {'control_body' 'control_joy' 'test_body' 'test_joy'};

%%
subject = 1
for subject = subjects
	disp(['Subject #' num2str(subject)]);
	STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
	
	input_filepath = fullfile(input_path, num2str(subject));
	
	%% load 
	EEG = pop_loadset('filename', strcat(filenames, '_EEG.set'), 'filepath', input_filepath);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'study',0);
    
	%% merge
    % merges all files currently loaded in EEGLAB into one file and stores
    % the original filenames in EEG.etc.appended_files
    [ALLEEG EEG CURRENTSET] = bemobil_merge(ALLEEG,EEG,CURRENTSET,[1:length(ALLEEG)]);
    
	%% preprocess
	% enter chanlocs, remove unused channels, declare EOG, resample
	
	channel_locations_filepath = fullfile(chanloc_path,num2str(subject),channel_locations_filename);
   
	[ALLEEG EEG CURRENTSET] = bemobil_preprocess(ALLEEG, EEG, CURRENTSET, channel_locations_filepath,...
        channels_to_remove,eog_channels,resample_freq);

	%% Interpolation of chanlocs and switching of interchanged channels
	% This first has to be determined manually by looking at the 3D channel visualization at EEGLAB ->
	% Edit -> channel locations -> Plot 3-D (xyz) and checking if this are off somehow (e.g. if the
	% same electrode has been measured twice), or by checking the data (e.g. if green and yellow
	% electrode bands have been mixed up you see the blinks at the wrong data channel)
	compute_1_1_electrode_mixup
          
	%% interpolate bad channels
    % the function stores the interpolated channels in EEG.etc and saves a
    % data set
    [ALLEEG, EEG, CURRENTSET] = bemobil_interp( EEG , ALLEEG, CURRENTSET, removed_chans{subject});
    
	%% Compute average reference
    EEG = pop_reref( EEG, []);
    EEG = eeg_checkset( EEG );
    
    %% save on disk
    EEG = pop_saveset( EEG, 'filename','interpolated_avRef','filepath', input_filepath);
    disp('...done');
	
end
