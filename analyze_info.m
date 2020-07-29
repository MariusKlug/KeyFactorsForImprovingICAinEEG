
input_filepath = '..\data\SR\AMICAs\same_length2';

subjects = [1:7 9:20];

density_levels = [16 32 64 128 157];
conditions = {'joystick','steamvr'};
filter_freqs = [0 0.5:0.25:1.5 1.75:0.5:3.25 4.25];

load_original_data = 0;

%% load data
if load_original_data
	[all_timings,all_lengths] = deal(nan(...
		length(subjects),...
		length(conditions),...
		length(density_levels),...
		length(filter_freqs)));
	
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
					
					this_filename = ['s-' num2str(subject),...
						'_condition-' condition,...
						'_density-' num2str(density_level),...
						'_highpass-' num2str(filter_freq*100)...
						'_fixedOrder_dataset_info'];
					
					this_results = load([input_filepath filesep num2str(subject) filesep this_filename]);
					
					% store computation time in hours
					all_timings(i_subject,i_condition,i_density_level,i_filter_freq) = this_results.this_AMICA_time/3600;
					all_lengths(i_subject,i_condition,i_density_level,i_filter_freq) = this_results.dataset_length;
					
				end
			end
		end
	end
	save('plot_data\info_data','all_timings','all_lengths')
end

%%
load('plot_data\info_data')

%% plot settings

channel_legends = {'16','32','64','128','157'};
filter_freqs_adjusted = filter_freqs;
filter_freqs_adjusted(1) = 0.25;
filter_freqs_adjusted = filter_freqs_adjusted-0.25;


plot_types = [1 2 3 7];
plot_type_names = {'Brain','Muscle','Eye','Other'};
condition_names = {'Stationary','Mobile'};

%% computation time
% 0 and 4 were computed on an overclocked CPU

size(all_timings);

means_over_subs = squeeze(mean(all_timings));

size(means_over_subs)

newfig(1); clf;
subplot(211)
imagesc(squeeze(means_over_subs(1,:,:)));
title(['Stationary, sum = ' num2str(round(sum(sum(sum(all_timings(:,1,:,:)))))) ' hours'])
axis xy
xticks(1:11)
xticklabels(filter_freqs_adjusted)
yticklabels(channel_legends)

colorbar

subplot(212)
imagesc(squeeze(means_over_subs(2,:,:)));
title(['Mobile, sum = ' num2str(round(sum(sum(sum(all_timings(:,2,:,:)))))) ' hours'])
axis xy
xticks(1:11)
xticklabels(filter_freqs_adjusted)
yticklabels(channel_legends)

colorbar

%% lengths
size(all_lengths)

mean(all_lengths(:,1,1,1) / 250 / 60)
std(all_lengths(:,1,1,1) / 250 / 60)

