if ~exist('ALLEEG','var')
	eeglab
end

subjects = [1:7 9:20];

density_levels = [15 16 32 64 128 157];
conditions = {'joystick','steamvr'};
filter_freqs = [0 0.5:0.25:1.5 1.75:0.5:3.25 4.25];
classifier_versions = {'default', 'lite'};

%%

for i_subject = 1:length(subjects)
	subject = subjects(i_subject)
	
	
	for i_density_level = 1:length(density_levels)
		density_level = density_levels(i_density_level);
		
		for i_condition = 1:length(conditions)
			condition = conditions{i_condition};
			
			for i_filter_freq = 1:length(filter_freqs)
				filter_freq = filter_freqs(i_filter_freq);
				
				for i_classifier_version = 1:length(classifier_versions)
					classifier_version = classifier_versions{i_classifier_version};
					
					this_filename = ['s-' num2str(subject),...
						'_condition-' condition,...
						'_density-' num2str(density_level),...
						'_highpass-' num2str(filter_freq*100)...
						'_fixedOrder_final_unfiltered_' classifier_version...
						]
					
					%% load data
					EEG = pop_loadset('filename',...
						[this_filename '.set'],'filepath',...
						['V:\\AMICA_investigation\\data\\SR\\AMICAs\\same_length2\' num2str(subject)]);
					
					%% save RV
					% this does nothing else than saving the rv data again,
					% it's only there because of a legacy bug that
					% translates to the present. don't do this at home!
					[all_rv] = deal(nan(157,1));
					
					all_rv(1:length([EEG.dipfit.model.rv])) = [EEG.dipfit.model.rv];
					
					save(['V:\\AMICA_investigation\\data\\SR\\AMICAs\\same_length2\'...
						num2str(subject) '\' this_filename '_all_RVs'],...
						'all_rv')
				end
			end
		end
	end
end
