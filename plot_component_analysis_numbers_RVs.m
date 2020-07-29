
input_filepath = '..\data\SR\AMICAs\same_length2';

subjects = [1:7 9:20];

classifier_versions = {'default' 'lite'};

i_classifier_version = 1; % change this to select default(1)/lite(2)!

classifier_version = classifier_versions{i_classifier_version};

use_detrend = 0;
density_levels = [16 32 64 128 157];
conditions = {'joystick','steamvr'};
filter_freqs = [0 0.5:0.25:1.5 1.75:0.5:3.25 4.25];

load_original_data = 0;
do_export = 0;

mkdir('..\analysis\plots\component_analysis\')

%% load data

if load_original_data
	[all_class, all_rv] = deal(nan(...
		length(subjects),...
		length(conditions),...
		length(density_levels),...
		length(filter_freqs),...
		157));
	all_pattern_RV = nan(...
		length(subjects),...
		length(conditions),...
		length(density_levels),...
		length(filter_freqs),...
		2);
	for i_subject = 1:length(subjects)
		subject = subjects(i_subject)
		
		for i_density_level = 1:length(density_levels)
			density_level = density_levels(i_density_level);
			
			for i_condition = 1:length(conditions)
				condition = conditions{i_condition};
				
				if ~use_detrend
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
							'_fixedOrder_final_features_' classifier_version];
						
						this_all_rv_filename = ['s-' num2str(subject),...
							'_condition-' condition,...
							'_density-' num2str(density_level),...
							'_highpass-' num2str(filter_freq*100)...
							'_fixedOrder_final_unfiltered_' classifier_version '.set_all_RVs']; % yes this is unintended but it works, i just rolled with it
						
						this_patterns_filename = ['s-' num2str(subject),...
							'_condition-' condition,...
							'_density-' num2str(density_level),...
							'_highpass-' num2str(filter_freq*100)...
							'_fixedOrder_final_frontoparietal_dipolarity_features'];
						
						this_results = load([input_filepath filesep num2str(subject) filesep this_filename]);
						
						% i had to recompute the lower density rv's
						% because the warping model did not work any
						% more for them and i didn't think about that
						% in the beginning. even though the bug is fixed in
						% the latest version of the AMICA computations, it
						% remains as a legacy "feature" here because we
						% never recomputed the entire dataset. the script
						% "save_dipole_fitting_RVs_with_correct_transform"
						% needs to be run before this.
						
						this_all_rv_results = load([input_filepath filesep num2str(subject) filesep this_all_rv_filename],'-mat');  % need to specifically tell matlab to read this as a mat file...
						
						% store in mat
						all_class(i_subject,i_condition,i_density_level,i_filter_freq,1:length(this_results.all_class)) =...
							this_results.all_class;
						all_rv(i_subject,i_condition,i_density_level,i_filter_freq,1:length(this_results.all_rv)) = ...
							this_all_rv_results.all_rv;
						
						% patterns could only reliably be found with 64 and
						% more channels
						try
							if ismember(density_level,[64, 128, 157])
								this_patterns_results = load([input_filepath filesep num2str(subject) filesep this_patterns_filename]);
								
								all_pattern_RV(i_subject,i_condition,i_density_level,i_filter_freq,1) = this_patterns_results.frontal_RV;
								all_pattern_RV(i_subject,i_condition,i_density_level,i_filter_freq,2) = this_patterns_results.parietal_RV;
							end
						catch
							warning('pattern results not found:')
							subject
							density_level
							condition
							filter_freq
							% s7 steamvr 157 0Hz has no IC with RV<0.1
							% s7 is excluded anyways in pattern analysis
							% because the detection did not work well
						end
						
					end
				end
			end
		end
	end
	
	save(['plot_data\component_analysis_data_unfiltered_' classifier_version],'all_class','all_rv','all_pattern_RV')
	disp('Feature extraction done!')
end

%%
load(['plot_data\component_analysis_data_unfiltered_' classifier_version])

%% plot settings
channel_legends = {'16','32','64','128','157'};

% log scale
filter_freqs_adjusted = filter_freqs;
filter_freqs_adjusted(1) = 0.25;
filter_freqs_adjusted = filter_freqs_adjusted-0.25;
filter_freqs_adjusted = log(filter_freqs_adjusted+1);

plot_types = [1 2 3 7];
plot_type_names = {'Brain','Muscle','Eye','Other'};
condition_names = {'Stationary','Mobile'};

% https://github.com/ZedThree/nemorb_matlab/blob/master/diverging_map.m
myCmap = diverging_map([1:256]/256, [0.230, 0.299, 0.754],[0.706, 0.016, 0.150]);

%% plots of numbers and RVs

newfig(201);clf; set(gcf,'position',[137 652 1585 617])
joycolors = [
	0.7,0.1,.5
	0.6,0.2,0.55
	0.5,0.4,0.6
	0.3,0.6,0.65
	0.0,0.7,0.75
	];
physcolors = [
	0.7,0.1,.5
	0.6,0.2,0.55
	0.5,0.4,0.6
	0.3,0.6,0.65
	0.0,0.7,0.75
	];

linewidth = 1.5;

for i_type = 1:length(plot_types)
	
	type = plot_types(i_type);
	subplot(2,4,i_type)
	
	all_data_this_type = squeeze(nansum(all_class(:,:,:,:,:)==type,5));
	[joylinehandles, areahandles] = errorarea(repmat(filter_freqs_adjusted,5,1)',...
		squeeze(mean(all_data_this_type(:,1,:,:)))',...
		squeeze(sem(all_data_this_type(:,1,:,:)))',linewidth);
	
	xticks(filter_freqs_adjusted([1 3 5 8 11]))
	xticklabels(exp(filter_freqs_adjusted([1 3 5 8 11]))-1)
	xlabel(['High-pass filter cutoff [Hz]' newline ' '])
	
	for i = 1:length(areahandles)
		areahandles(i).FaceColor = joycolors(i,:);
	end
	for i = 1:length(joylinehandles)
		joylinehandles(i).Color = joycolors(i,:);
	end
	
	[joylinehandles([1]).LineStyle] = deal('-');
	[joylinehandles([2]).LineStyle] = deal('-');
	[joylinehandles([3]).LineStyle] = deal('-');
	[joylinehandles([4]).LineStyle] = deal('-');
	[joylinehandles([5]).LineStyle] = deal('-');
	
	set(gca,'fontsize',12);
	
	hold on
	[physlinehandles, areahandles] = errorarea(repmat(filter_freqs_adjusted,5,1)',...
		squeeze(mean(all_data_this_type(:,2,:,:)))',...
		squeeze(sem(all_data_this_type(:,2,:,:)))',linewidth)
	
	for i = 1:length(areahandles)
		areahandles(i).FaceColor = physcolors(i,:);
	end
	for i = 1:length(joylinehandles)
		physlinehandles(i).Color = physcolors(i,:);
	end
	
	[physlinehandles([1]).LineStyle] = deal('-.');
	[physlinehandles([2]).LineStyle] = deal('-.');
	[physlinehandles([3]).LineStyle] = deal('-.');
	[physlinehandles([4]).LineStyle] = deal('-.');
	[physlinehandles([5]).LineStyle] = deal('-.');
	
	xlabel(['High-pass filter cutoff [Hz]' newline ' '])
	
	grid on
	title(['# of ' plot_type_names{i_type} ' ICs'])
	
	
	ylims = ylim;
	ylim([0 ylims(2)]);
	
	set(gca,'fontsize',12);
	ax = gca;
	ax.XRuler.MinorTickValues = filter_freqs_adjusted;
	ax.XMinorGrid = 'on';
end

% RV as second row
for i_type = 1:length(plot_types)
	
	type = plot_types(i_type);
	subplot(2,4,i_type+4)
	
	% rv
	this_rv = all_rv;
	
	this_rv(all_class(:,:,:,:,:)~=type) = NaN;
	all_data_this_type = squeeze(nanmean(this_rv,5));
	
	[joylinehandles, areahandles] = errorarea(repmat(filter_freqs_adjusted,5,1)',...
		squeeze(nanmean(all_data_this_type(:,1,:,:)))',...
		squeeze(sem(all_data_this_type(:,1,:,:)))',linewidth);
	
	xticks(filter_freqs_adjusted([1 3 5 8 11]))
	xticklabels(exp(filter_freqs_adjusted([1 3 5 8 11]))-1)
	xlabel(['High-pass filter cutoff [Hz]' ])
	
	for i = 1:length(areahandles)
		areahandles(i).FaceColor = joycolors(i,:);
	end
	for i = 1:length(joylinehandles)
		joylinehandles(i).Color = joycolors(i,:);
	end
	
	[joylinehandles([1]).LineStyle] = deal('-');
	[joylinehandles([2]).LineStyle] = deal('-');
	[joylinehandles([3]).LineStyle] = deal('-');
	[joylinehandles([4]).LineStyle] = deal('-');
	[joylinehandles([5]).LineStyle] = deal('-');
	
	set(gca,'fontsize',12);
	
	hold on
	[physlinehandles, areahandles] = errorarea(repmat(filter_freqs_adjusted,5,1)',...
		squeeze(nanmean(all_data_this_type(:,2,:,:)))',...
		squeeze(sem(all_data_this_type(:,2,:,:)))',linewidth)
	
	for i = 1:length(areahandles)
		areahandles(i).FaceColor = physcolors(i,:);
	end
	for i = 1:length(joylinehandles)
		physlinehandles(i).Color = physcolors(i,:);
	end
	
	[physlinehandles([1]).LineStyle] = deal('-.');
	[physlinehandles([2]).LineStyle] = deal('-.');
	[physlinehandles([3]).LineStyle] = deal('-.');
	[physlinehandles([4]).LineStyle] = deal('-.');
	[physlinehandles([5]).LineStyle] = deal('-.');
	
	xlabel(['High-pass filter cutoff [Hz]' ])
	
	grid on
	title([plot_type_names{i_type} ' ICs mean RV'])
	
	ylims = ylim;
	ylim([0 ylims(2)]);
	
	set(gca,'fontsize',12);
	ax = gca;
	ax.XRuler.MinorTickValues = filter_freqs_adjusted;
	ax.XMinorGrid = 'on';
end

l = legend(flipud([physlinehandles;joylinehandles]),fliplr({...
	['Mobile ' num2str(density_levels(1))],...
	['Mobile ' num2str(density_levels(2))],...
	['Mobile ' num2str(density_levels(3))],...
	['Mobile ' num2str(density_levels(4))],...
	['Mobile ' num2str(density_levels(5))],...
	['Stationary ' num2str(density_levels(1))],...
	['Stationary ' num2str(density_levels(2))],...
	['Stationary ' num2str(density_levels(3))],...
	['Stationary ' num2str(density_levels(4))],...
	['Stationary ' num2str(density_levels(5))]}),...
	'position',[0.9185 0.3896 0.0662 0.2893],'fontsize',10);


%%
if do_export
	export_fig_all(['..\analysis\plots\component_analysis\numbersAndRV_reviewed_' classifier_version],gcf,0,1)
end

%% parietal RVs

newfig(210);clf; set(gcf,'position',[137 872 761 397])
joycolors = [
	0.7,0.2,.5
	0.6,0.3,0.55
	0.7,0.1,.5
	0.5,0.4,0.6
	0.0,0.7,0.75
	];
physcolors = [
	0.7,0.2,.5
	0.6,0.3,0.55
	0.7,0.1,.5
	0.5,0.4,0.6
	0.0,0.7,0.75
	];


linewidth = 1.5;

subjects_to_include = 1:19; % s8 was excluded before, higher s moved down
subjects_to_include([4 7]) = []; % exclude subjects from pattern analysis because pattern recognition did not work well
all_data_this_type = squeeze(all_pattern_RV(subjects_to_include,:,:,:,2)); % for checking parietal individually


[joylinehandles, areahandles] = errorarea(repmat(filter_freqs_adjusted,5,1)',...
	squeeze(mean(all_data_this_type(:,1,:,:)))',...
	squeeze(sem(all_data_this_type(:,1,:,:)))',linewidth);

xticks(filter_freqs_adjusted([1 3 5 8 11]))
xticklabels(exp(filter_freqs_adjusted([1 3 5 8 11]))-1)
xlabel(['High-pass filter cutoff [Hz]' newline ' '])

for i = 1:length(areahandles)
	areahandles(i).FaceColor = joycolors(i,:);
end
for i = 1:length(joylinehandles)
	joylinehandles(i).Color = joycolors(i,:);
end

[joylinehandles([1]).LineStyle] = deal('-');
[joylinehandles([2]).LineStyle] = deal('-');
[joylinehandles([3]).LineStyle] = deal('-');
[joylinehandles([4]).LineStyle] = deal('-');
[joylinehandles([5]).LineStyle] = deal('-');

set(gca,'fontsize',12);

hold on
[physlinehandles, areahandles] = errorarea(repmat(filter_freqs_adjusted,5,1)',...
	squeeze(mean(all_data_this_type(:,2,:,:)))',...
	squeeze(sem(all_data_this_type(:,2,:,:)))',linewidth)

for i = 1:length(areahandles)
	areahandles(i).FaceColor = physcolors(i,:);
end
for i = 1:length(joylinehandles)
	physlinehandles(i).Color = physcolors(i,:);
end

[physlinehandles([1]).LineStyle] = deal('-.');
[physlinehandles([2]).LineStyle] = deal('-.');
[physlinehandles([3]).LineStyle] = deal('-.');
[physlinehandles([4]).LineStyle] = deal('-.');
[physlinehandles([5]).LineStyle] = deal('-.');

xlabel(['High-pass filter cutoff [Hz]' newline ' '])

grid on
title(['Residual Variance of Parietal Patterns'])

set(gca,'fontsize',12);

ax = gca;
ax.XRuler.MinorTickValues = filter_freqs_adjusted;
ax.XMinorGrid = 'on';

l = legend(flipud([physlinehandles(3:5);joylinehandles(3:5)]),fliplr({...
	['Mobile ' num2str(density_levels(3))],...
	['Mobile ' num2str(density_levels(4))],...
	['Mobile ' num2str(density_levels(5))],...
	['Stationary ' num2str(density_levels(3))],...
	['Stationary ' num2str(density_levels(4))],...
	['Stationary ' num2str(density_levels(5))]}),...
	'location','eastoutside','fontsize',10);

%%
if do_export
	export_fig_all(['..\analysis\plots\component_analysis\parietal_RVs'],gcf,0,1)
end
