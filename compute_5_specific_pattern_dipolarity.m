if ~exist('ALLEEG','var')
	eeglab
end
addpath('P:\Marius\toolboxes\export_fig') %https://de.mathworks.com/matlabcentral/fileexchange/23629-export_fig

subjects = [1:7 9:20];

density_levels = [64 128 157]; % only high-density worked
conditions = {'joystick','steamvr'};
filter_freqs = [0 0.5:0.25:1.5 1.75:0.5:3.25 4.25];

input_filepath = '..\\data\\SR\\AMICAs\\same_length2\';

%%

				
for i_subject = 1:length(subjects)
	subject = subjects(i_subject)
	
	
	for i_density_level = 1:length(density_levels)
		density_level = density_levels(i_density_level);
		
		for i_condition = 1:length(conditions)
			condition = conditions{i_condition};
			
			for i_filter_freq = 1:length(filter_freqs)
				
				% load data
				% 						subject
				% 						density_level
				% 						condition
				filter_freq = filter_freqs(i_filter_freq);
				%%
				this_filename = ['s-' num2str(subject),...
					'_condition-' condition,...
					'_density-' num2str(density_level),...
					'_highpass-' num2str(filter_freq*100)...
					'_fixedOrder_final_unfiltered_lite.set'];
				
						
				this_all_rv_filename = ['s-' num2str(subject),...
					'_condition-' condition,...
					'_density-' num2str(density_level),...
					'_highpass-' num2str(filter_freq*100)...
					'_fixedOrder_final_unfiltered_lite.set_all_RVs'];

				%% load data
				EEG = pop_loadset('filename',...
					this_filename,'filepath',...
					[input_filepath num2str(subject)]);
				this_all_rv_results = load([input_filepath filesep num2str(subject) filesep this_all_rv_filename],'-mat');

				%% only take first ICs and remove ones with rv>0.1 to only select brain parietal ICs
				this_ICA_weights = EEG.icawinv(:,1:round(size(EEG.icawinv,2)/3)+10);
				all_RV = this_all_rv_results.all_rv(~isnan(this_all_rv_results.all_rv));

				all_RV = all_RV(1:round(size(EEG.icawinv,2)/3)+10);
				
				this_ICA_weights(:,all_RV>0.1) = [];
				all_RV(all_RV>0.1) = [];
				
				%% find parietooccipital channel indices
				
				negative_channames = {};
				negative_channames = {};
				positive_channames = {'r23','r24','w14'};
				zero_channames = {'g16','g32','y5','y23','w20','w8','w28','r11','r18','y15','g22','g2','g30','w30','w2','w24','y28','y4','r18',...
					'y5','g10','y23','y20','g19'};
				
				negative_chanindices = [];
				
				for i_frontal_channame = 1:length(negative_channames)
					negative_chanindices(end+1) = find(strcmp({EEG.chanlocs.labels},negative_channames{i_frontal_channame}));
				end
				
				positive_chanindices = [];
				
				for i_parietal_channame = 1:length(positive_channames)
					positive_chanindices(end+1) = find(strcmp({EEG.chanlocs.labels},positive_channames{i_parietal_channame}));
				end
				
				zero_chanindices = [];
				
				for i_irrelevant_channame = 1:length(zero_channames)
					zero_chanindices(end+1) = find(strcmp({EEG.chanlocs.labels},zero_channames{i_irrelevant_channame}));
				end
				
				negative_weights = this_ICA_weights(negative_chanindices,:);
				% take absolute to account for inverted polarity
				scaled_negative_weights = abs(mean(-1 * negative_weights ./ max(abs(this_ICA_weights),[],1)));
				scaled_negative_weights = 0
				% worked better without
				
				positive_weights = this_ICA_weights(positive_chanindices,:);
				% take absolute to account for inverted polarity
				scaled_positive_weights = 1 * abs(mean(positive_weights ./ max(abs(this_ICA_weights),[],1)));
				
				zero_weights = this_ICA_weights(zero_chanindices,:);
				% negative after takig the absolute because they should be
				% close to zero
				scaled_zero_weights = 2*mean(-1 * abs(zero_weights) ./ max(abs(this_ICA_weights),[],1));
				
				sum_weights = scaled_negative_weights+scaled_positive_weights+scaled_zero_weights;
				
				parietal_pattern = find(sum_weights == max(sum_weights));
				parietal_RV = all_RV(parietal_pattern);
				parietal_weight = max(sum_weights);
				
				this_fig = figure(2); clf;
				set(gcf,'color','w','position',[4 793 1324 558]);
				subplot(121)
				topoplot(this_ICA_weights(:,parietal_pattern),EEG.chanlocs,'electrodes','labels')
				title({EEG.filename,['Pattern: ' num2str(parietal_pattern) ', weight = ' num2str(parietal_weight)...
					', RV = ' num2str(parietal_RV)]},'interpreter', 'none')
				
				
				%% find frontal channel indices
				% unfortunately this did not work well enough to be
				% included in the analysis later
				
				positive_channames = {'y15','y14','y17','y12','y20'};
				negative_channames = {'w2','w22','w26'};
				zero_channames = {'g5','g16','g32','g25','y5','y6','y8','y24','y23','r11','r32','g2','g30','g22','g10',...
					'w2','w22','w26','r23','r24','w14'};
				
				negative_chanindices = [];
				
				for i_frontal_channame = 1:length(negative_channames)
					negative_chanindices(end+1) = find(strcmp({EEG.chanlocs.labels},negative_channames{i_frontal_channame}));
				end
				
				positive_chanindices = [];
				
				for i_parietal_channame = 1:length(positive_channames)
					positive_chanindices(end+1) = find(strcmp({EEG.chanlocs.labels},positive_channames{i_parietal_channame}));
				end
				
				zero_chanindices = [];
				
				for i_irrelevant_channame = 1:length(zero_channames)
					zero_chanindices(end+1) = find(strcmp({EEG.chanlocs.labels},zero_channames{i_irrelevant_channame}));
				end
				
				negative_weights = this_ICA_weights(negative_chanindices,:);
				% take absolute to account for inverted polarity
				scaled_negative_weights = abs(mean(-1 * negative_weights ./ max(abs(this_ICA_weights),[],1)));
				scaled_negative_weights = 0;
				% worked better without
				
				positive_weights = this_ICA_weights(positive_chanindices,:);
				% take absolute to account for inverted polarity
				scaled_positive_weights = 1*abs(max(positive_weights ./ max(abs(this_ICA_weights),[],1)));
				
				zero_weights = this_ICA_weights(zero_chanindices,:);
				% negative after takig the absolute because they should be
				% close to zero
				scaled_zero_weights = 2*mean(-1 * abs(zero_weights) ./ max(abs(this_ICA_weights),[],1));
				
				sum_weights = scaled_negative_weights+scaled_positive_weights+scaled_zero_weights;
				
				frontal_pattern_idx = find(sum_weights == max(sum_weights));
				frontal_pattern = this_ICA_weights(:,frontal_pattern_idx);
				frontal_RV = all_RV(frontal_pattern_idx);
				frontal_weight = max(sum_weights);
				
				figure(this_fig)
				subplot(122)
				topoplot(frontal_pattern,EEG.chanlocs,'electrodes','labels')
				title({EEG.filename,['Pattern: ' num2str(frontal_pattern_idx) ', weight = ' num2str(frontal_weight)...
					', RV = ' num2str(frontal_RV)]},'interpreter', 'none')
				
				
				%% save
				
				save(['..\\data\\SR\\AMICAs\\same_length2\' num2str(subject)...
					'\s-' num2str(subject),...
					'_condition-' condition,...
					'_density-' num2str(density_level),...
					'_highpass-' num2str(filter_freq*100)...
					'_fixedOrder_final_frontoparietal_dipolarity_features'],...
					'frontal_pattern','frontal_RV','frontal_weight','parietal_pattern','parietal_RV','parietal_weight')
				
				export_fig_all(['..\\data\\SR\\AMICAs\\same_length2\' num2str(subject)...
					'\s-' num2str(subject),...
					'_condition-' condition,...
					'_density-' num2str(density_level),...
					'_highpass-' num2str(filter_freq*100)...
					'_fixedOrder_final_frontoparietal_dipolarity_patterns'],this_fig,1)
				
			end
		end
	end
end

return

%% for testing in between
for pattern = 1:size(this_ICA_weights,2)
	figure;
	topoplot(this_ICA_weights(:,pattern),EEG.chanlocs,'electrodes','labels')
				title({EEG.filename,['Pattern: ' num2str(pattern) ', RV = ' num2str(all_RV(pattern))...
					', weight=' num2str(sum_weights(pattern))...
					', pos=' num2str(scaled_positive_weights(pattern))...
					', zero=' num2str(scaled_zero_weights(pattern))...
					]},...
					'interpreter', 'none');
end