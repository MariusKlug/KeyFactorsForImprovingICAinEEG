compute_AMICA_investigation_settings;
matlab_instance = 10;

% userpath('reset')
% cd('C:\Users\marius\Documents\MATLAB')
% cd(userpath)

% make sure the correct eeglab version is loaded whichever PC is used
rmpath('M:\Toolboxes_Skripts_and_Coding_examples\eeglab-by-marius\eeglab14_1_0b')
addpath('P:\Marius\toolboxes')
addpath('P:\Marius\toolboxes\eeglab14_1_0b')

% don't use subject 8
subjects = [1:7 9:20];

classifier_versions = {'default', 'lite'};

% make sure same length for stationary and mobile is used
use_same_length = 1;

% set filter order
use_fixed_order = 1;
filter_order = 1650;

switch matlab_instance
	%c045
	case 1
		filter_freqs = [0.5];
	case 2
		filter_freqs = [0.75];
	case 3
		filter_freqs = [1];
		%c047
	case 4
		filter_freqs = [1.25];
	case 5
		filter_freqs = [1.5];
	case 6
		filter_freqs = [1.75];
		%c051
	case 7
		filter_freqs = [2.25];
	case 8
		filter_freqs = [2.75];
	case 9
		filter_freqs = [3.25];
		%c046
	case 10
		filter_freqs = [4.25];
	case 11
		filter_freqs = [0];
end

% 15 channels is a proxy for the dorsal 16 channel layout
density_levels = [15 16 32 64 128 157];

% DO NOT SPLIT UP! It will mess up the condition boundaries. 
conditions = {'steamvr','joystick'};

filter_freqs = [0 0.5:0.25:1.5 1.75:0.5:3.25 4.25] % for checking all

%% ICA loop

% raw data is on a different server
input_path = '\\130.149.173.137\projects\Lukas_Gehrke\studies\Spot_Rotation\data\2_raw_EEGLAB\';
if use_same_length
	output_path = '\\130.149.173.137\archives\AMICA_investigation\data\SR\AMICAs\same_length2\';
else
	output_path = '\\130.149.173.137\archives\AMICA_investigation\data\SR\AMICAs\';
end

if ~exist('ALLEEG','var'); eeglab; end
pop_editoptions( 'option_storedisk', 0, 'option_savetwofiles', 1, 'option_saveversion6', 0, 'option_single', 0, 'option_memmapdata', 0, 'option_eegobject', 0, 'option_computeica', 1, 'option_scaleicarms', 1, 'option_rememberfolder', 1, 'option_donotusetoolboxes', 0, 'option_checkversion', 1, 'option_chat', 1);

loop_subject = 1
for loop_subject = subjects
	disp(['Subject #' num2str(loop_subject)]);
	
	input_filepath = [input_path num2str(loop_subject)];
	output_filepath = [output_path num2str(loop_subject)];
	if use_same_length
		savepath_preAMICA = ['\\130.149.173.137\archives\AMICA_investigation\data\SR\preprocessed\same_length2\' num2str(loop_subject)];
	else
		savepath_preAMICA = ['\\130.149.173.137\archives\AMICA_investigation\data\SR\preprocessed\' num2str(loop_subject)];
	end
	for i_density = 1:length(density_levels)
		loop_density = density_levels(i_density);
		
		for i_condition = 1:length(conditions)
			loop_condition = conditions{i_condition};
			
			for i_filter_freq = 1:length(filter_freqs)
				
				%% load data
				loop_subject
				loop_density
				loop_condition
				loop_filter_freq = filter_freqs(i_filter_freq)
				
				[all_class, all_rv] = deal(nan(157,1));
				all_iclabel_classifications = nan(157,7);
				
				this_filename = ['s-' num2str(loop_subject),...
					'_condition-' loop_condition,...
					'_density-' num2str(loop_density),...
					'_highpass-' num2str(loop_filter_freq*100) '_'];
				
				if use_fixed_order
					this_filename = [this_filename 'fixedOrder_'];
				end
				
				files = dir(output_filepath);
				all_filenames = {files.name}';
				
				if any(strcmp(all_filenames,[this_filename 'dataset_info.mat'])) &&...
						any(strcmp(all_filenames,[this_filename 'final_unfiltered_default.set'])) &&...
						any(strcmp(all_filenames,[this_filename 'final_unfiltered_lite.set'])) &&...
						any(strcmp(all_filenames,[this_filename 'final_features_default.mat'])) &&...
						any(strcmp(all_filenames,[this_filename 'final_features_lite.mat']))
					% all these files should exist if the dataset was
					% fully processed
					disp('-----------------------------------------------------------')
					disp('File had been computed already!')
					disp('-----------------------------------------------------------')
% 					continue
				end
				
				STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
				
				EEG_basic = pop_loadset('filename', 'interpolated_avRef.set', 'filepath', input_filepath);
				[ALLEEG EEG_basic CURRENTSET] = pop_newset(ALLEEG, EEG_basic, 0,'study',0);
				
				
				%% delete channels
				switch loop_density
					
					case 15
						
						% throw neck out and subsample scalp electrodes as good as possible
						delete_electrodes = {'g1' 'g2' 'g3' 'g4' 'g5' 'g6' 'g7' 'g8',...
							'g10' 'g11' 'g12' 'g13' 'g14' 'g15' 'g17' 'g18' 'g19' 'g20',...
							'g21' 'g22' 'g23' 'g24' 'g25' 'g26' 'g27' 'g28' 'g29' 'g30' 'g31' 'g32',...
							'y2' 'y4' 'y5' 'y6' 'y7' 'y8' 'y9' 'y11' 'y12' 'y13' 'y14',...
						    'y17' 'y18' 'y19' 'y20' 'y21' 'y23' 'y24' 'y25' 'y26',...
							'y27' 'y29' 'y31' 'r1' 'r2' 'r3',....
							'r4' 'r5' 'r6' 'r7' 'r9' 'r10' 'r11' 'r12' 'r13' 'r14' 'r15',...
							'r16' 'r17' 'r18' 'r19' 'r20' 'r21' 'r22' 'r24',...
							'r26' 'r27' 'r28' 'r29' 'r30' 'r31' 'r32' 'w1' 'w2' 'w3' 'w4',...
							'w5' 'w6' 'w7' 'w8' 'w9' 'w10' 'w11' 'w12' 'w14' 'w15' 'w16',...
							'w17' 'w19' 'w20' 'w21' 'w22' 'w23' 'w24' 'w25' 'w26' 'w27',...
							'w28' 'w29' 'w30' 'w31' 'w32' 'n1' 'n2' 'n3' 'n4' 'n5',...
							'n6' 'n7' 'n8' 'n9' 'n10' 'n11' 'n12' 'n13' 'n14' 'n15',...
							'n16' 'n17' 'n18' 'n19' 'n20' 'n21' 'n22' 'n23' 'n24',...
							'n25' 'n26' 'n27' 'n28' 'n32'};
						
						EEG_basic = pop_select( EEG_basic,'nochannel',delete_electrodes);
						
						% determine rank of data
						all_chanlocs = EEG_basic.urchanlocs;
						
						% only valid channels for rank remain
						all_chanlocs(EEG_basic.etc.interpolated_channels) = [];
						
						counting_for_rank = [];
						
						% check for each channel in the dataset if it is a valid channel for rank
						for i = 1:length({EEG_basic.chanlocs.labels})
							
							if any(strcmp({all_chanlocs.labels},EEG_basic.chanlocs(i).labels))
								counting_for_rank(i) = 1;
							end
							
						end
						
						% rank is reduced by 1 in addition due to average reference
						data_rank = sum(counting_for_rank) - 1;
						
					case 16
						
						% throw neck out and subsample scalp electrodes as good as possible
						delete_electrodes = {'g1' 'g2' 'g3' 'g4' 'g5' 'g6' 'g7' 'g8',...
							'g9' 'g11' 'g12' 'g13' 'g14' 'g15' 'g17' 'g18' 'g19' 'g20',...
							'g21' 'g23' 'g24' 'g25' 'g26' 'g27' 'g28' 'g29' 'g30' 'g31' 'y1',...
							'y2' 'y3' 'y4' 'y5' 'y7' 'y8' 'y9' 'y10' 'y11' 'y12' 'y13' 'y14',...
							'y16' 'y17' 'y18' 'y19' 'y20' 'y21' 'y22' 'y23' 'y24' 'y25',...
							'y27' 'y29' 'y30' 'y31' 'y32' 'r1' 'r2' 'r3',....
							'r4' 'r5' 'r7' 'r8' 'r9' 'r10' 'r11' 'r12' 'r13' 'r14' 'r15',...
							'r16' 'r17' 'r18' 'r19' 'r20' 'r21' 'r22' 'r24' 'r25',...
							'r26' 'r28' 'r29' 'r30' 'r31' 'r32' 'w1' 'w2' 'w3' 'w4',...
							'w5' 'w6' 'w7' 'w9' 'w11' 'w12' 'w13' 'w14' 'w15' 'w16',...
							'w17' 'w18' 'w19' 'w20' 'w23' 'w25' 'w26' 'w27',...
							'w28' 'w29' 'w30' 'w31' 'w32' 'n1' 'n2' 'n3' 'n4' 'n5',...
							'n6' 'n7' 'n8' 'n9' 'n10' 'n11' 'n12' 'n13' 'n14' 'n15',...
							'n16' 'n17' 'n18' 'n19' 'n20' 'n21' 'n22' 'n23' 'n24',...
							'n25' 'n26' 'n27' 'n28' 'n32'};
						
						EEG_basic = pop_select( EEG_basic,'nochannel',delete_electrodes);
						
						% determine rank of data
						all_chanlocs = EEG_basic.urchanlocs;
						
						% only valid channels for rank remain
						all_chanlocs(EEG_basic.etc.interpolated_channels) = [];
						
						counting_for_rank = [];
						
						% check for each channel in the dataset if it is a valid channel for rank
						for i = 1:length({EEG_basic.chanlocs.labels})
							
							if any(strcmp({all_chanlocs.labels},EEG_basic.chanlocs(i).labels))
								counting_for_rank(i) = 1;
							end
							
						end
						
						% rank is reduced by 1 in addition due to average reference
						data_rank = sum(counting_for_rank) - 1;
						
					case 32
						
						% throw neck out and subsample scalp electrodes as good as possible
						delete_electrodes = {'g5','g27','g19','g13','y23','y17',...
							'g2','g30','w32','r14','r11','r30','w26',...
							'r22','w20','w5','y24'...
							'y4','g25','g7','y8','r16','r4','y18','y6',...
							'g1','g3','g4','g6','g8','g9','g11','g12','g14','g18', 'g20',...
							'g21','g23','g24','g26','g28','g29','g31',...
							'y1','y2','y3','y9','y11','y12','y13','y15','y16','y19','y21','y25','y27','y29','r18','y31',...
							'r1','r6','r3','r7','r8','r9','r13','r15','r17','r19','r21','r24','r25','r27','r29','r31','r32',...
							'w1','w3','w4','w6','w7','w9','w11','w12','w13','w14', 'w15','w16','w18','w19','w22','w23','w25','w27','w29','w30',...
							'n1' 'n2' 'n3' 'n4' 'n5' 'n6' 'n7' 'n8' 'n9' 'n10' 'n11' 'n12' 'n13' 'n14' 'n15' 'n16' 'n17' 'n18' 'n19' 'n20' 'n21' 'n22' 'n23' 'n24' 'n25' 'n26' 'n27' 'n28' 'n32'};
						EEG_basic = pop_select( EEG_basic,'nochannel',delete_electrodes);
						
						% determine rank of data
						all_chanlocs = EEG_basic.urchanlocs;
						
						% only valid channels for rank remain
						all_chanlocs(EEG_basic.etc.interpolated_channels) = [];
						
						counting_for_rank = [];
						
						% check for each channel in the dataset if it is a valid channel for rank
						for i = 1:length({EEG_basic.chanlocs.labels})
							
							if any(strcmp({all_chanlocs.labels},EEG_basic.chanlocs(i).labels))
								counting_for_rank(i) = 1;
							end
							
						end
						
						% rank is reduced by 1 in addition due to average reference
						data_rank = sum(counting_for_rank) - 1;
						
					case 64
						
						% throw neck out and subsample scalp electrodes as good as possible
						delete_electrodes = {'g1','g3','g4','g6','g8','g9','g11','g12','g15','g17', 'g20',...
							'g21','g23','g24','g26','g28','g29','g31',...
							'y1','y2','y7','y9','y11','y13','y16','y19','y21','y22','y25','y27','y29','y31',...
							'r1','r2','r3','r5','r7','r9','r15','r17','r19','r21','r25','r27','r29','r31',...
							'w1','w3','w4','w6','w7','w9','w11','w12','w15','w16','w17','w19','w21','w23','w25','w27','w29','w31',...
							'n1' 'n2' 'n3' 'n4' 'n5' 'n6' 'n7' 'n8' 'n9' 'n10' 'n11' 'n12' 'n13' 'n14' 'n15' 'n16' 'n17' 'n18' 'n19' 'n20' 'n21' 'n22' 'n23' 'n24' 'n25' 'n26' 'n27' 'n28' 'n32'};
						EEG_basic = pop_select( EEG_basic,'nochannel',delete_electrodes);
						
						% determine rank of data
						all_chanlocs = EEG_basic.urchanlocs;
						
						% only valid channels for rank remain
						all_chanlocs(EEG_basic.etc.interpolated_channels) = [];
						
						counting_for_rank = [];
						
						% check for each channel in the dataset if it is a valid channel for rank
						for i = 1:length({EEG_basic.chanlocs.labels})
							
							if any(strcmp({all_chanlocs.labels},EEG_basic.chanlocs(i).labels))
								counting_for_rank(i) = 1;
							end
							
						end
						
						% rank is reduced by 1 in addition due to average reference
						data_rank = sum(counting_for_rank) - 1;
						
					case 128
						% throw neck out
						EEG_basic = pop_select( EEG_basic,'nochannel',{'n1' 'n2' 'n3' 'n4' 'n5' 'n6' 'n7' 'n8' 'n9' 'n10' 'n11' 'n12' 'n13' 'n14' 'n15' 'n16' 'n17' 'n18' 'n19' 'n20' 'n21' 'n22' 'n23' 'n24' 'n25' 'n26' 'n27' 'n28' 'n32'});
						
						
						
					case 157
						
					otherwise
						error(['unknown density level: ' num2str(loop_density)])
				end
				
				%% apply filter
				
				if loop_filter_freq ~= 0
					% filters the data set, stores all relevant info in the set
					if use_fixed_order
						[ALLEEG, EEG, CURRENTSET] = bemobil_filter(ALLEEG, EEG_basic, CURRENTSET,...
							loop_filter_freq,[],[],[],filter_order);
					else
						[ALLEEG, EEG, CURRENTSET] = bemobil_filter(ALLEEG, EEG_basic, CURRENTSET,...
							loop_filter_freq, []);
					end
				else
					EEG = EEG_basic;
					EEG.etc.filter = 'not applied';
				end
				
				%% clean data based on manual cleaning info
				% the matrix is filled in the settings file
				for segmenting_step = 1:size(rejections_segments(loop_subject,:),2) % maybe it was not done in one go
					if ~isempty(rejections_segments{loop_subject,segmenting_step})
						EEG = eeg_eegrej( EEG, rejections_segments{loop_subject,segmenting_step});
					end
				end
				
				for cleaning_step = 1:size(rejections_cleaning(loop_subject,:),2) % maybe it was not done in one go
					if ~isempty(rejections_cleaning{loop_subject,cleaning_step})
						EEG = eeg_eegrej( EEG, rejections_cleaning{loop_subject,cleaning_step});
					end
				end
				
				%% select condition
				
				dataset_events = {EEG.event.type};
				
				condition_lengths = nan(3,1);
				condition_lengths(3) = EEG.pnts;
				condition_latencies = nan(length(conditions),2); % check start and end indices too
				condition_indices = nan(length(conditions),2); % check start and end indices too
				condition_events = cell(length(conditions),2);
				
				for i_condition2 = 1:length(conditions)
					selection_condition = conditions{i_condition2};
					
					this_condition_events = ~cellfun(@isempty,regexp(dataset_events,['outward_rotation:' selection_condition]));
					
					assert(any(this_condition_events),['No events found for condition: ' selection_condition])
					
					first_event = find(this_condition_events,1,'first');
					condition_indices(i_condition2,1) = first_event;
					condition_events{i_condition2,1} = dataset_events(first_event);
					last_event = find(this_condition_events,1,'last');
					condition_indices(i_condition2,2) = last_event;
					condition_events{i_condition2,2} = dataset_events(last_event);
					
					condition_lengths(i_condition2) = round(EEG.event(last_event).latency - EEG.event(first_event).latency) - 1;
					condition_latencies(i_condition2,:) = round([EEG.event(first_event).latency; EEG.event(last_event).latency]);
				end
				
				
				% reject such that the length is the same but the datasets
				% are distinct
				rejection_window = [0 condition_latencies(i_condition,1);
					condition_latencies(i_condition,1)+min(condition_lengths)+1 condition_lengths(3)];
				
				EEG = eeg_eegrej( EEG, rejection_window);
				
				dataset_length = EEG.pnts;
				
				%% determine rank of data
				all_chanlocs = EEG.urchanlocs;
				
				% only valid channels for rank remain
				all_chanlocs(EEG.etc.interpolated_channels) = [];
				
				counting_for_rank = [];
				
				% check for each channel in the dataset if it is a valid channel for rank
				for i = 1:length({EEG.chanlocs.labels})
					
					if any(strcmp({all_chanlocs.labels},EEG.chanlocs(i).labels))
						counting_for_rank(i) = 1;
					end
					
				end
				
				% rank is reduced by 1 in addition due to average reference
				data_rank = sum(counting_for_rank) - 1;
				
				%% save dataset so a datfile is present for AMICA
				
				% delete events first to save space
				EEG.event = [];
				EEG.urevent = [];
				
				mkdir(savepath_preAMICA)
				EEG = pop_saveset( EEG, 'filename',[this_filename 'pre-AMICA'],'filepath', savepath_preAMICA);
				disp('...done');
				
				%% finally run AMICA, copy into unfiltered dataset
				
				tic;
				[ALLEEG EEG CURRENTSET] = bemobil_signal_decomposition(ALLEEG, EEG, CURRENTSET, true, num_models, max_threads,...
					data_rank, []);
				this_AMICA_time = toc;
				
				% copy ICA
				disp('Copying ICA weights from provided data set.');
				EEG_basic.icaweights = EEG.icaweights;
				EEG_basic.icasphere = EEG.icasphere;
				
				% recompute the rest of ICA stuff
				EEG_basic = eeg_checkset( EEG_basic );
				
				if isfield(EEG.etc,'spatial_filter')
					
					EEG_basic.etc.spatial_filter = EEG.etc.spatial_filter;
					EEG_basic.etc.spatial_filter.old_etc = EEG.etc;
					
				end
				
				EEG = EEG_basic;
				
				%% clean unfiltered dataset the same way as the filtered
				
				% manual cleaning
				for segmenting_step = 1:size(rejections_segments(loop_subject,:),2) % maybe it was not done in one go
					if ~isempty(rejections_segments{loop_subject,segmenting_step})
						EEG = eeg_eegrej( EEG, rejections_segments{loop_subject,segmenting_step});
					end
				end
				
				for cleaning_step = 1:size(rejections_cleaning(loop_subject,:),2) % maybe it was not done in one go
					if ~isempty(rejections_cleaning{loop_subject,cleaning_step})
						EEG = eeg_eegrej( EEG, rejections_cleaning{loop_subject,cleaning_step});
					end
				end
				
				% condition selection
				EEG = eeg_eegrej( EEG, rejection_window);
				
				%% fit dipoles
				
				% dipole fitting with correct transform:
				% channel locations need to be warped to correspond to the
				% MNI brain. This is done based on a transformation matrix.
				% transforms are based on warping with 157 channels, for
				% every subject, these are now used for all warps of this
				% subject
				
				this_warping_transform = warping_transforms(loop_subject,:);
				eeglab_base_path = fileparts(which('eeglab'));

				EEG = pop_dipfit_settings( EEG, 'hdmfile',[eeglab_base_path '\\plugins\\dipfit2.3\\standard_BEM\\standard_vol.mat'],...
					'coordformat','MNI',...
					'mrifile',[eeglab_base_path '\\plugins\\dipfit2.3\\standard_BEM\\standard_mri.mat'],...
					'chanfile',[eeglab_base_path '\\plugins\\dipfit2.3\\standard_BEM\\elec\\standard_1005.elc'],...
					'coord_transform',this_warping_transform ,...
					'chansel',[1:EEG.nbchan] );
				
				EEG = pop_multifit(EEG, [1:size(EEG.icaweights,1)] ,'threshold',residualVariance_threshold,...
					'dipoles', number_of_dipoles, 'rmout', do_remove_outside_head);
				
				%% run iclabel, store in mat and save data
				for i_classifier_version = 1:length(classifier_versions)
					
					classifier_version = classifier_versions{i_classifier_version};
					EEG = iclabel(EEG,classifier_version);
					mkdir(output_filepath)
					pop_saveset(EEG,'filename',[this_filename 'final_unfiltered_' classifier_version], 'filepath',output_filepath)
					
					[all_class, all_rv] = deal(nan(157,1));
					all_iclabel_classifications = nan(157,7);
					
					all_iclabel_classifications(1:size(EEG.etc.ic_classification.ICLabel.classifications,1),:)=...
						EEG.etc.ic_classification.ICLabel.classifications;
					
					[row ~] = find(transpose(EEG.etc.ic_classification.ICLabel.classifications==max(EEG.etc.ic_classification.ICLabel.classifications,[],2)));
					
					all_class(1:length(EEG.etc.ic_classification.ICLabel.classifications)) = row;
					
					all_rv(1:length([EEG.dipfit.model.rv])) = [EEG.dipfit.model.rv];
					
					save([output_filepath filesep this_filename 'final_features_' classifier_version],...
						'all_iclabel_classifications','all_class','all_rv')
					
				end
				
				save([output_filepath filesep this_filename 'dataset_info'],...
					'loop_condition','i_condition','rejection_window','this_AMICA_time',...
					'dataset_length','condition_lengths','condition_events',...
					'condition_latencies','condition_indices')
				
			end % filter
			
		end % condition
		
	end % density
	
end % subject

disp('ALL DONE \o/')


