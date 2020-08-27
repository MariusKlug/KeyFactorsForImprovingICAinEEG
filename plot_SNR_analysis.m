addpath('P:\Marius\toolboxes\export_fig') %https://de.mathworks.com/matlabcentral/fileexchange/23629-export_fig

x_times_original = -600:4:1200;
plot_start = -600;
plot_end = 1200;
P3start = 250;
P3end = 450;
prestim_noise_start = -500;
prestim_noise_end = 0;


subjects = [1:7 9:20];

filter_freqs = [0 0.5:0.25:1.5 1.75:0.5:3.25 4.25];

classifier_versions = {'default', 'lite'};


load_original_data = 0;
do_export = 0;

mkdir('..\analysis\plots\SNRs\')

%%

if load_original_data
	clear all_data ERP_SNR ERPs
	
	for subject = subjects
		subject
		for i_filter_freq = 1:length(filter_freqs)
			filter_freq = filter_freqs(i_filter_freq);
			for i_classifier_version = 1:length(classifier_versions)
				classifier_version = classifier_versions{i_classifier_version};
				
				% load data and figure
				
				this_data = load(['..\analysis\SNR\' num2str(subject) '\s-' num2str(subject)...
					'_highpass-' num2str(filter_freq*100) '_' classifier_version '_SNR-data']);
				
				all_ERP_data(subject,i_filter_freq,i_classifier_version) = this_data.this_data;
				
				ERP_SNR(subject,i_filter_freq,i_classifier_version,:,:) = this_data.this_data.ERP_SNRs;
				ERPs(subject,i_filter_freq,i_classifier_version,:,:,:) = this_data.this_data.ERPs;
				
			end
		end
	end
	
	% remove 8 (filled with zeros because s8 was removed)
	all_ERP_data(8,:,:) = []
	ERP_SNR(8,:,:,:,:) = [];
	ERPs(8,:,:,:,:,:) = [];
	
	save('plot_data/ERP_data','all_ERP_data','ERP_SNR','ERPs')
end

%%

load('plot_data/ERP_data')
% average number of epochs
mean([all_ERP_data(1:19).n_epochs])
std([all_ERP_data(1:19).n_epochs])

%% average number of epochs
mean([all_ERP_data(1:19).n_epochs])
std([all_ERP_data(1:19).n_epochs])

%% plot SNRs

% subjects, filterfreqs, classifier, condition, density (uncleaned, 16-157)

channel_layouts_to_use = [1 3:7];
classifier_version_to_plot = 2; % lite classifier

channel_legends = {'no ICA','15','16','32','64','128','157'};
channel_legends = channel_legends(channel_layouts_to_use);

filter_freqs_adjusted = filter_freqs;
filter_freqs_adjusted(1) = 0.25;
filter_freqs_adjusted = filter_freqs_adjusted-0.25;

newfig(2); clf


subplot(221)
imagesc(squeeze(mean(squeeze(ERP_SNR(:,:,classifier_version_to_plot,1,channel_layouts_to_use))))',[0 4])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel('High-pass filter cutoff for ICA cleaning [Hz]')
axis xy
colorbar

title('Mean SNR for Stationary')
set(gca,'fontsize',12);


subplot(222)
imagesc(squeeze(mean(squeeze(ERP_SNR(:,:,classifier_version_to_plot,2,channel_layouts_to_use))))',[0 4])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel('High-pass filter cutoff for ICA cleaning [Hz]')
axis xy
colorbar

title('Mean SNR for Mobile')
set(gca,'fontsize',12);


subplot(223)
imagesc(squeeze(std(squeeze(ERP_SNR(:,:,classifier_version_to_plot,1,channel_layouts_to_use))))',[2 6])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel('High-pass filter cutoff for ICA cleaning [Hz]')
axis xy
colorbar

title('SNR Standard Deviation for Stationary')
set(gca,'fontsize',12);


subplot(224)
imagesc(squeeze(std(squeeze(ERP_SNR(:,:,classifier_version_to_plot,2,channel_layouts_to_use))))',[2 6])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel('High-pass filter cutoff for ICA cleaning [Hz]')
axis xy
colorbar

title('SNR Standard Deviation for Mobile')
set(gca,'fontsize',12);

colormap jet
colormap(othercolor('OrRd6')) % https://de.mathworks.com/matlabcentral/fileexchange/30564-othercolor
setfigpos(1.06*[550 297 1566 737])

%%
if do_export
	export_fig_all('..\analysis\plots\SNRs\reviewed',figure(2),0,1)
end

%% plot ERPs lite
% subjects, filterfreqs, classifier, condition, density (uncleaned, 16-157)

classifier_version_to_plot = 2; % lite classifier

P3_idx = find(x_times_original>=P3start,1,'first'):find(x_times_original<P3end,1,'last');
ERP_idx = find(x_times_original>=plot_start,1,'first'):find(x_times_original<plot_end,1,'last');


x_times = x_times_original(ERP_idx);

linestyle = '-';
linewidth = 1;

colors_density =  [0.2 linspace(0.7,0.0,5)
	0.2 [linspace(0,0.5,2) 0.75 linspace(0.5,0,2)]
	0.2 linspace(0.0,0.7,5)]';

signal_color = [0.85 0.85 0.85];
noise_color = [0.7 0.7 0.7];

colors_density =[
	0.2,0.2,0.2
	1, 0,0
	0.7,0.1,.5
	0.6,0.2,0.55
	0.5,0.4,0.6
	0.3,0.6,0.65
	0.0,0.7,0.75];
colors_filters =  [linspace(0.6,0.0,11)
	[linspace(0,0.6,5) 0.65 linspace(0.6,0,5)]
	linspace(0.0,0.6,11)]';

tempfreqs = filter_freqs;
tempfreqs(1) = 0.25;
tempfreqs = tempfreqs-0.25;
temp={num2str(tempfreqs')};
filter_legends = strcat(temp{:},'Hz');
channel_legends = {'no ICA cleaning','16 channels','32 channels','64 channels','128 channels','157 channels'};

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(10);clf;set(gcf,'color','w')
setfigpos(round([100 400 998 140]*0.8809*2));
subplot(121)
hold on

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)
fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,3,classifier_version_to_plot,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end

% https://de.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline
hline(0,'k'); 
vline(0,'k');

title('Stationary cleaned with 0.5Hz high-pass filtered ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])
yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,3,classifier_version_to_plot,2,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Mobile cleaned with 0.5Hz high-pass filtered ICA')

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(11);clf;set(gcf,'color','w')
setfigpos(round([100 400 998 140]*0.8809*2));
subplot(121)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,1,channel_layouts_to_use(5),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');

title('Stationary cleaned with 128 channels ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,2,channel_layouts_to_use(5),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Mobile cleaned with 128 channels ICA')


%%%%%%%%%%%%%%%%%%%%%%%%%
figure(12);clf;set(gcf,'color','w')

setfigpos(round([100 400 998 140]*0.8809*2));

subplot(121)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,classifier_version_to_plot,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Stationary cleaned with 1.25Hz high-pass filtered ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])


yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,classifier_version_to_plot,2,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Mobile cleaned with 1.25Hz high-pass filtered ICA')

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(13);clf;set(gcf,'color','w')
setfigpos(round([100 400 998 140]*0.8809*2));
subplot(121)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,1,channel_layouts_to_use(4),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Stationary cleaned with 64 channels ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)



hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top')

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,2,channel_layouts_to_use(4),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Mobile cleaned with 64 channels ICA')

% plot for legends only
%%%%%%%%%%%%%%%%%%%%%
figure(14);clf;set(gcf,'color','w')
setfigpos(0.8809*2*[319 200 502 418]);
subplot(131)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-2 -2 4.5 4.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,1,channel_layouts_to_use(4),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');
legend(handles,filter_legends,'location','eastoutside')
title('Stationary cleaned with 64 channels ICA')

subplot(132)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

area_handles(1) = fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
area_handles(2) = fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-2 -2 4.5 4.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,classifier_version_to_plot,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

legend(handles(channel_layouts_to_use),channel_legends,'location','eastoutside')
title('Stationary cleaned with 1.25Hz high-pass filtered ICA')


subplot(133)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

area_handles(1) = fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
area_handles(2) = fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-2 -2 4.5 4.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,classifier_version_to_plot,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

legend(area_handles,{'signal range' 'noise range'},'location','eastoutside')
title('Stationary cleaned with 1.25Hz high-pass filtered ICA')



%% save
if do_export
	export_fig_all('..\analysis\plots\ERPs\50Hz_reviewed',figure(10),0)
	export_fig_all('..\analysis\plots\ERPs\128chan_reviewed',figure(11),0)
	export_fig_all('..\analysis\plots\ERPs\125Hz_reviewed',figure(12),0)
	export_fig_all('..\analysis\plots\ERPs\64chan_reviewed',figure(13),0)
	export_fig_all('..\analysis\plots\ERPs\legends_reviewed',figure(14),0)
end

%% plot SNRs default classifier
classifier_version_to_plot = 1;

% subjects, filterfreqs, classifier, condition, density (uncleaned, 16-157)

channel_layouts_to_use = [1:7]; % include dorsal layout just for check

channel_legends = {'no ICA','16 dorsal','16 whole head','32','64','128','157'};
channel_legends = channel_legends(channel_layouts_to_use);

filter_freqs_adjusted = filter_freqs;
filter_freqs_adjusted(1) = 0.25;
filter_freqs_adjusted = filter_freqs_adjusted-0.25;

newfig(3); clf


subplot(221)
imagesc(squeeze(mean(squeeze(ERP_SNR(:,:,classifier_version_to_plot,1,channel_layouts_to_use))))',[0 4])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel('High-pass filter cutoff for ICA cleaning [Hz]')
axis xy
colorbar

title('Mean SNR for Stationary')
set(gca,'fontsize',12);


subplot(222)
imagesc(squeeze(mean(squeeze(ERP_SNR(:,:,classifier_version_to_plot,2,channel_layouts_to_use))))',[0 4])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel('High-pass filter cutoff for ICA cleaning [Hz]')
axis xy
colorbar

title('Mean SNR for Mobile')
set(gca,'fontsize',12);


subplot(223)
imagesc(squeeze(std(squeeze(ERP_SNR(:,:,classifier_version_to_plot,1,channel_layouts_to_use))))',[2 6])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel('High-pass filter cutoff for ICA cleaning [Hz]')
axis xy
colorbar

title('SNR Standard Deviation for Stationary')
set(gca,'fontsize',12);


subplot(224)
imagesc(squeeze(std(squeeze(ERP_SNR(:,:,classifier_version_to_plot,2,channel_layouts_to_use))))',[2 6])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel('High-pass filter cutoff for ICA cleaning [Hz]')
axis xy
colorbar

title('SNR Standard Deviation for Mobile')
set(gca,'fontsize',12);

colormap jet
colormap(othercolor('OrRd6')) % https://de.mathworks.com/matlabcentral/fileexchange/30564-othercolor
setfigpos([583 214 1660 882])

%%
if do_export
	export_fig_all('..\analysis\plots\SNRs\default_ICLabel',figure(3),0,1)
end

%% plot ERPs default
% subjects, filterfreqs, classifier, condition, density (uncleaned, 16-157)

classifier_version_to_plot = 1;

P3_idx = find(x_times_original>=P3start,1,'first'):find(x_times_original<P3end,1,'last');
ERP_idx = find(x_times_original>=plot_start,1,'first'):find(x_times_original<plot_end,1,'last');


x_times = x_times_original(ERP_idx);

linestyle = '-';

colors_density =  [0.2 linspace(0.7,0.0,5)
	0.2 [linspace(0,0.5,2) 0.75 linspace(0.5,0,2)]
	0.2 linspace(0.0,0.7,5)]';

signal_color = [0.85 0.85 0.85];
noise_color = [0.7 0.7 0.7];

colors_density =[
	0.2,0.2,0.2
	1, 0,0
	0.7,0.1,.5
	0.6,0.2,0.55
	0.5,0.4,0.6
	0.3,0.6,0.65
	0.0,0.7,0.75];
colors_filters =  [linspace(0.6,0.0,11)
	[linspace(0,0.6,5) 0.65 linspace(0.6,0,5)]
	linspace(0.0,0.6,11)]';

tempfreqs = filter_freqs;
tempfreqs(1) = 0.25;
tempfreqs = tempfreqs-0.25;
temp={num2str(tempfreqs')};
filter_legends = strcat(temp{:},'Hz');
channel_legends = {'no ICA cleaning','16 channels','32 channels','64 channels','128 channels','157 channels'};

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(100);clf;set(gcf,'color','w')
setfigpos(round([100 400 998 140]*0.8809*2));
subplot(121)
hold on

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)
fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,3,classifier_version_to_plot,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end

hline(0,'k'); 
vline(0,'k');

title('Stationary cleaned with 0.5Hz high-pass filtered ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])
yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,3,classifier_version_to_plot,2,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Mobile cleaned with 0.5Hz high-pass filtered ICA')

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(110);clf;set(gcf,'color','w')
setfigpos(round([100 400 998 140]*0.8809*2));
subplot(121)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,1,channel_layouts_to_use(5),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');

title('Stationary cleaned with 128 channels ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,2,channel_layouts_to_use(5),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Mobile cleaned with 128 channels ICA')


%%%%%%%%%%%%%%%%%%%%%%%%%
figure(120);clf;set(gcf,'color','w')

setfigpos(round([100 400 998 140]*0.8809*2));

subplot(121)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,classifier_version_to_plot,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Stationary cleaned with 1.25Hz high-pass filtered ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])


yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,classifier_version_to_plot,2,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Mobile cleaned with 1.25Hz high-pass filtered ICA')

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(130);clf;set(gcf,'color','w')
setfigpos(round([100 400 998 140]*0.8809*2));
subplot(121)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,1,channel_layouts_to_use(4),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Stationary cleaned with 64 channels ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)



hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top')

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,2,channel_layouts_to_use(4),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

title('Mobile cleaned with 64 channels ICA')

% plot for legends only
%%%%%%%%%%%%%%%%%%%%%
figure(140);clf;set(gcf,'color','w')
setfigpos(0.8809*2*[319 200 502 418]);
subplot(131)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-2 -2 4.5 4.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,classifier_version_to_plot,1,channel_layouts_to_use(4),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');
legend(handles,filter_legends,'location','eastoutside')
title('Stationary cleaned with 64 channels ICA')

subplot(132)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

area_handles(1) = fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
area_handles(2) = fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-2 -2 4.5 4.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,classifier_version_to_plot,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

legend(handles(channel_layouts_to_use),channel_legends,'location','eastoutside')
title('Stationary cleaned with 1.25Hz high-pass filtered ICA')


subplot(133)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

area_handles(1) = fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
area_handles(2) = fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-2 -2 4.5 4.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,classifier_version_to_plot,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end


hline(0,'k');
vline(0,'k');

legend(area_handles,{'signal range' 'noise range'},'location','eastoutside')
title('Stationary cleaned with 1.25Hz high-pass filtered ICA')


%% save
if do_export
	export_fig_all('..\analysis\plots\ERPs\50Hz_default_ICLabel',figure(100),0)
	export_fig_all('..\analysis\plots\ERPs\128chan_default_ICLabel',figure(110),0)
	export_fig_all('..\analysis\plots\ERPs\125Hz_default_ICLabel',figure(120),0)
	export_fig_all('..\analysis\plots\ERPs\64chan_default_ICLabel',figure(130),0)
	export_fig_all('..\analysis\plots\ERPs\legends_default_ICLabel',figure(140),0)
end

%% plot SNR comparisons for 16-channel layouts

% subjects, filterfreqs, classifier, condition, density (uncleaned, 16-157)

channel_layouts_to_use = [1 2 3 6];

channel_legends = {'no ICA','16 dorsal','16 whole head','32','64','128','157'};
channel_legends = channel_legends(channel_layouts_to_use);

filter_freqs_adjusted = filter_freqs;
filter_freqs_adjusted(1) = 0.25;
filter_freqs_adjusted = filter_freqs_adjusted-0.25;

newfig(4); clf

subplot(221)
imagesc(squeeze(mean(squeeze(ERP_SNR(:,:,2,1,channel_layouts_to_use))))',[0 4])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel({'High-pass filter cutoff for ICA cleaning [Hz]',' '})
axis xy
colorbar

title('Mean SNR for Stationary')
set(gca,'fontsize',12);


subplot(222)
imagesc(squeeze(mean(squeeze(ERP_SNR(:,:,2,2,channel_layouts_to_use))))',[0 4])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel({'High-pass filter cutoff for ICA cleaning [Hz]',' '})
axis xy
colorbar

title('Mean SNR for Mobile')
set(gca,'fontsize',12);


subplot(223)
imagesc(squeeze(std(squeeze(ERP_SNR(:,:,2,1,channel_layouts_to_use))))',[2 6])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel({'High-pass filter cutoff for ICA cleaning [Hz]',' '})
axis xy
colorbar

title('SNR Standard Deviation for Stationary')
set(gca,'fontsize',12);


subplot(224)
imagesc(squeeze(std(squeeze(ERP_SNR(:,:,2,2,channel_layouts_to_use))))',[2 6])
yticks(1:size(ERP_SNR,5))
yticklabels(channel_legends)
ylabel({'Channel montage' 'for ICA cleaning'})
xticks(1:11)
xticklabels(filter_freqs_adjusted)
xlabel({'High-pass filter cutoff for ICA cleaning [Hz]',' '})
axis xy
colorbar

title('SNR Standard Deviation for Mobile')
set(gca,'fontsize',12);

colormap jet
colormap(othercolor('OrRd6')) % https://de.mathworks.com/matlabcentral/fileexchange/30564-othercolor
setfigpos([583 487 1660 609])

%%
if do_export
	export_fig_all('..\analysis\plots\SNRs\comparison16layouts',figure(4),0,1)
end

%% plot ERPs for 16 channel comparisons
% subjects, filterfreqs, classifier, condition, density (uncleaned, 16-157)

P3_idx = find(x_times_original>=P3start,1,'first'):find(x_times_original<P3end,1,'last');
ERP_idx = find(x_times_original>=plot_start,1,'first'):find(x_times_original<plot_end,1,'last');
			

x_times = x_times_original(ERP_idx);

linestyle = '-';

signal_color = [0.85 0.85 0.85];
noise_color = [0.7 0.7 0.7];

colors_density =[
	0.2,0.2,0.2
	1, 0,0
	0.7,0.1,.5
	0.6,0.2,0.55
	0.5,0.4,0.6
	0.3,0.6,0.65
	0.0,0.7,0.75];
colors_filters =  [linspace(0.6,0.0,11)
	[linspace(0,0.6,5) 0.65 linspace(0.6,0,5)]
	linspace(0.0,0.6,11)]';

tempfreqs = filter_freqs;
tempfreqs(1) = 0.25;
tempfreqs = tempfreqs-0.25;
temp={num2str(tempfreqs')};
filter_legends = strcat(temp{:},'Hz');
channel_legends = {'no ICA cleaning','16 channels dorsal','16 channels whole head','128 channels'};

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1000);clf;set(gcf,'color','w')
setfigpos(round([100 400 998 140]*0.8809*2));
subplot(121)
hold on

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)
fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,3,2,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');
title('Stationary cleaned with 0.5Hz high-pass filtered ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])
yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,3,2,2,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');

title('Mobile cleaned with 0.5Hz high-pass filtered ICA')

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1100);clf;set(gcf,'color','w')
setfigpos(round([100 400 998 140]*0.8809*2));
subplot(121)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,2,1,channel_layouts_to_use(3),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');
title('Stationary cleaned with 16 channels ICA whole head')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,2,2,channel_layouts_to_use(3),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');
title('Stationary cleaned with 16 channels ICA whole head')
	

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1200);clf;set(gcf,'color','w')

setfigpos(round([100 400 998 140]*0.8809*2));

subplot(121)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,2,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');

title('Stationary cleaned with 1.25Hz high-pass filtered ICA')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])


yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,2,2,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end
hline(0,'k');
vline(0,'k');
title('Mobile cleaned with 1.25Hz high-pass filtered ICA')

%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1300);clf;set(gcf,'color','w')
setfigpos(round([100 400 998 140]*0.8809*2));
subplot(121)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,2,1,channel_layouts_to_use(2),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');
title('Stationary cleaned with 16 channels ICA dorsal')

subplot(122)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)



hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-1.5 -1.5 1.5 1.5],noise_color,'edgecolor',noise_color)
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top')


ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,2,2,channel_layouts_to_use(2),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');
title('Stationary cleaned with 16 channels ICA dorsal')

% plot for legends only
%%%%%%%%%%%%%%%%%%%%%
figure(1400);clf;set(gcf,'color','w')
setfigpos(0.8809*2*[319 200 502 418]);
subplot(131)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)

hold on

fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-2 -2 4.5 4.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = 1:size(ERPs,2)
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,i,2,1,channel_layouts_to_use(4),ERP_idx))))','LineWidth', linewidth,...
		'color',colors_filters(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');
legend(handles,filter_legends,'location','eastoutside')
title('Stationary cleaned with 64 channels ICA')

subplot(132)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

area_handles(1) = fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
area_handles(2) = fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-2 -2 4.5 4.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,2,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');

legend(handles(channel_layouts_to_use),channel_legends,'location','eastoutside')
title('Stationary cleaned with 1.25Hz high-pass filtered ICA')


subplot(133)

set(gca, 'YGrid','on');  set(gca,'fontsize',12);xlim([plot_start plot_end]);ylim([-2.5 5])

yticks(-2:2:4)
xticks(-400:200:1000)


hold on

area_handles(1) = fill([P3start P3end P3end P3start], [-2 -2 4.5 4.5],signal_color,'edgecolor',signal_color);
area_handles(2) = fill([prestim_noise_start prestim_noise_end prestim_noise_end prestim_noise_start],...
	[-2 -2 4.5 4.5],noise_color,'edgecolor',noise_color)

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca, 'Layer', 'top');
clear handles
for i = channel_layouts_to_use
	handles(i) = plot(x_times,squeeze(mean(squeeze(ERPs(:,6,2,1,i,ERP_idx))))','LineWidth', linewidth,...
		'color',colors_density(i,:),'linestyle',linestyle);
end

hline(0,'k');
vline(0,'k');

legend(area_handles,{'signal range' 'noise range'},'location','eastoutside')
title('Stationary cleaned with 1.25Hz high-pass filtered ICA')



%% save
if do_export
	export_fig_all('..\analysis\plots\ERPs\50Hz_comparison16layouts',figure(1000),0)
	export_fig_all('..\analysis\plots\ERPs\wholehead_comparison16layouts',figure(1100),0)
	export_fig_all('..\analysis\plots\ERPs\125Hz_comparison16layouts',figure(1200),0)
	export_fig_all('..\analysis\plots\ERPs\dorsal_comparison16layouts',figure(1300),0)
	export_fig_all('..\analysis\plots\ERPs\legends_comparison16layouts',figure(1400),0)
end