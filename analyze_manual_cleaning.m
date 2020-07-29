% check amount of removed samples for the segmenting and manual cleaning 

compute_1_AMICA_investigation_settings

%% load all full datasets
subjects = [1:7 9:20];

clear alldata

for subject = subjects
	
	alldata(subject) = pop_loadset('filename',...
		['s-' num2str(subject) '_condition-joystick_density-157_highpass-0_fixedOrder_final_unfiltered_lite.set'],...
		'filepath',['V:\\AMICA_investigation\\data\\SR\\AMICAs\\same_length2\\' num2str(subject) '\\']);
	
end

%%
n_interpolated_channels = [];

for subject = subjects
	
	n_interpolated_channels(subject) = length(alldata(subject).etc.interpolated_channels);
	
end
n_interpolated_channels(8) = [];
mean(n_interpolated_channels)
std(n_interpolated_channels)

%%
AMICA_investigation_settings

rejection_lengths_segmenting = zeros(1,subjects(end));
rejection_lengths_cleaning = zeros(1,subjects(end));
dataset_lengths_original = zeros(1,subjects(end));
dataset_lengths_segments = zeros(1,subjects(end));

for subject = subjects
	
	% data lengths
	dataset_lengths_original(subject) = alldata(subject).times(end);
	
	% only experiment data segments
	first_segment_cleaning = rejections_segments{subject,1};
	second_segment_cleaning = rejections_segments{subject,2};
	
	rejection_lengths_segmenting(subject) = rejection_lengths_segmenting(subject) + ...
		sum(first_segment_cleaning(:,2) - first_segment_cleaning(:,1));
	if ~isempty(second_segment_cleaning)
		rejection_lengths_segmenting(subject) = rejection_lengths_segmenting(subject) + ...
			sum(second_segment_cleaning(:,2) - second_segment_cleaning(:,1));
	end
	
	% data lengths
	dataset_lengths_segments(subject) = alldata(subject).times(end) - rejection_lengths_segmenting(subject);
	
	% manual cleaning
	first_manual_cleaning = rejections_cleaning{subject,1};
	second_manual_cleaning = rejections_cleaning{subject,2};
	
	rejection_lengths_cleaning(subject) = rejection_lengths_cleaning(subject) + ...
		sum(first_manual_cleaning(:,2) - first_manual_cleaning(:,1));
	if ~isempty(second_manual_cleaning)
		rejection_lengths_cleaning(subject) = rejection_lengths_cleaning(subject) + ...
			sum(second_manual_cleaning(:,2) - second_manual_cleaning(:,1));
	end
	
end

proportion_removed_for_segmenting = rejection_lengths_segmenting./dataset_lengths_original*100;
proportion_removed_from_experiment_segments = rejection_lengths_cleaning./dataset_lengths_segments*100;

mean_cleaned = nanmean(proportion_removed_from_experiment_segments) %s8 is NaN
std_cleaned = nanstd(proportion_removed_from_experiment_segments)