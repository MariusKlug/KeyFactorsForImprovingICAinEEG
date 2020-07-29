% load
if ~exist('ALLEEG','var')
	eeglab % necessary for topoplots
end

addpath('P:\Marius\toolboxes\export_fig') %https://de.mathworks.com/matlabcentral/fileexchange/23629-export_fig

load_original_data = 0;
do_export = 0;

mkdir('..\analysis\plots\paradigm\')

%% only done once to load and save the topography data from subject 6 (nice centered layout)
if load_original_data
	
	EEG15 = pop_loadset('filename','s-6_condition-joystick_density-15_highpass-0_fixedOrder_final_unfiltered_lite.set','filepath','..\\data\\SR\\AMICAs\\same_length2\\6\\');
	EEG16 = pop_loadset('filename','s-6_condition-joystick_density-16_highpass-0_fixedOrder_final_unfiltered_lite.set','filepath','..\\data\\SR\\AMICAs\\same_length2\\6\\');
	EEG32 = pop_loadset('filename','s-6_condition-joystick_density-32_highpass-0_fixedOrder_final_unfiltered_lite.set','filepath','..\\data\\SR\\AMICAs\\same_length2\\6\\');
	EEG64 = pop_loadset('filename','s-6_condition-joystick_density-64_highpass-0_fixedOrder_final_unfiltered_lite.set','filepath','..\\data\\SR\\AMICAs\\same_length2\\6\\');
	EEG128 = pop_loadset('filename','s-6_condition-joystick_density-128_highpass-0_fixedOrder_final_unfiltered_lite.set','filepath','..\\data\\SR\\AMICAs\\same_length2\\6\\');
	EEG157 = pop_loadset('filename','s-6_condition-joystick_density-157_highpass-0_fixedOrder_final_unfiltered_lite.set','filepath','..\\data\\SR\\AMICAs\\same_length2\\6\\');
	
	EEG = EEG15;
	meanX = mean([EEG.chanlocs.X]);
	meanY = mean([EEG.chanlocs.Y]);
	meanZ = mean([EEG.chanlocs.Z]);
	EEG.chaninfo.nodatchans = [];
	EEG=pop_chanedit(EEG, 'append',1,'changefield',{2 'labels' 'MEAN'},...
		'changefield',{2 'X' meanX},'changefield',{2 'Y' meanY},...
		'changefield',{2 'Z' meanZ},'convert',{'cart2all'});
	EEG.chanlocs(end+1) = rmfield(EEG.chaninfo.nodatchans(end),'datachan');
	i=1;layout_data(i).chanlocs = EEG.chanlocs;
	layout_data(i).nbchan = EEG.nbchan;
	
	EEG = EEG16;
	meanX = mean([EEG.chanlocs.X]);
	meanY = mean([EEG.chanlocs.Y]);
	meanZ = mean([EEG.chanlocs.Z]);
	EEG.chaninfo.nodatchans = [];
	EEG=pop_chanedit(EEG, 'append',1,'changefield',{2 'labels' 'MEAN'},...
		'changefield',{2 'X' meanX},'changefield',{2 'Y' meanY},...
		'changefield',{2 'Z' meanZ},'convert',{'cart2all'});
	EEG.chanlocs(end+1) = rmfield(EEG.chaninfo.nodatchans(end),'datachan');
	i=i+1;layout_data(i).chanlocs = EEG.chanlocs;
	layout_data(i).nbchan = EEG.nbchan;
	
	EEG = EEG32;
	meanX = mean([EEG.chanlocs.X]);
	meanY = mean([EEG.chanlocs.Y]);
	meanZ = mean([EEG.chanlocs.Z]);
	EEG.chaninfo.nodatchans = [];
	EEG=pop_chanedit(EEG, 'append',1,'changefield',{2 'labels' 'MEAN'},...
		'changefield',{2 'X' meanX},'changefield',{2 'Y' meanY},...
		'changefield',{2 'Z' meanZ},'convert',{'cart2all'});
	EEG.chanlocs(end+1) = rmfield(EEG.chaninfo.nodatchans(end),'datachan');
	i=i+1;layout_data(i).chanlocs = EEG.chanlocs;
	layout_data(i).nbchan = EEG.nbchan;
	
	EEG = EEG64;
	meanX = mean([EEG.chanlocs.X]);
	meanY = mean([EEG.chanlocs.Y]);
	meanZ = mean([EEG.chanlocs.Z]);
	EEG.chaninfo.nodatchans = [];
	EEG=pop_chanedit(EEG, 'append',1,'changefield',{2 'labels' 'MEAN'},...
		'changefield',{2 'X' meanX},'changefield',{2 'Y' meanY},...
		'changefield',{2 'Z' meanZ},'convert',{'cart2all'});
	EEG.chanlocs(end+1) = rmfield(EEG.chaninfo.nodatchans(end),'datachan');
	i=i+1;layout_data(i).chanlocs = EEG.chanlocs;
	layout_data(i).nbchan = EEG.nbchan;
	
	EEG = EEG128;
	meanX = mean([EEG.chanlocs.X]);
	meanY = mean([EEG.chanlocs.Y]);
	meanZ = mean([EEG.chanlocs.Z]);
	EEG.chaninfo.nodatchans = [];
	EEG=pop_chanedit(EEG, 'append',1,'changefield',{2 'labels' 'MEAN'},...
		'changefield',{2 'X' meanX},'changefield',{2 'Y' meanY},...
		'changefield',{2 'Z' meanZ},'convert',{'cart2all'});
	EEG.chanlocs(end+1) = rmfield(EEG.chaninfo.nodatchans(end),'datachan');
	i=i+1;layout_data(i).chanlocs = EEG.chanlocs;
	layout_data(i).nbchan = EEG.nbchan;
	
	EEG = EEG157;
	meanX = mean([EEG.chanlocs.X]);
	meanY = mean([EEG.chanlocs.Y]);
	meanZ = mean([EEG.chanlocs.Z]);
	EEG.chaninfo.nodatchans = [];
	EEG=pop_chanedit(EEG, 'append',1,'changefield',{2 'labels' 'MEAN'},...
		'changefield',{2 'X' meanX},'changefield',{2 'Y' meanY},...
		'changefield',{2 'Z' meanZ},'convert',{'cart2all'});
	EEG.chanlocs(end+1) = rmfield(EEG.chaninfo.nodatchans(end),'datachan');
	i=i+1;layout_data(i).chanlocs = EEG.chanlocs;
	layout_data(i).nbchan = EEG.nbchan;
	
	save('plot_data\layout_data','layout_data')
end

%% plot 5 topographies for channel density levels

load('plot_data\layout_data')

figure(2);clf;set(gcf,'color','w');set(gcf,'position',[504 693 1675 457])

% EEG 16
subplot(151)

EEG = layout_data(2);

topoplot(zeros(EEG.nbchan+1,1),EEG.chanlocs,'electrodes','on','emsize',30)
set(findobj(gca,'type','patch'),'facecolor','w');
plotlines = findobj(gca,'type','line');
plotlines(1).XData(1:end-1) = [];
plotlines(1).YData(1:end-1) = [];
plotlines(1).ZData(1:end-1) = [];
plotlines(1).Color = [0.9 0 0];

EEG.chanlocs(end) = [];

topoplot(zeros(EEG.nbchan,1),EEG.chanlocs,'electrodes','on','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');

% EEG 32
subplot(152)

EEG = layout_data(3);

topoplot(zeros(EEG.nbchan+1,1),EEG.chanlocs,'electrodes','on','emsize',30)
set(findobj(gca,'type','patch'),'facecolor','w');
plotlines = findobj(gca,'type','line');
plotlines(1).XData(1:end-1) = [];
plotlines(1).YData(1:end-1) = [];
plotlines(1).ZData(1:end-1) = [];
plotlines(1).Color = [0.9 0 0];

EEG.chanlocs(end) = [];

topoplot(zeros(EEG.nbchan,1),EEG.chanlocs,'electrodes','on','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');

% EEG64
subplot(153)

EEG = layout_data(4);

topoplot(zeros(EEG.nbchan+1,1),EEG.chanlocs,'electrodes','on','emsize',30)
set(findobj(gca,'type','patch'),'facecolor','w');
plotlines = findobj(gca,'type','line');
plotlines(1).XData(1:end-1) = [];
plotlines(1).YData(1:end-1) = [];
plotlines(1).ZData(1:end-1) = [];
plotlines(1).Color = [0.9 0 0];

EEG.chanlocs(end) = [];

topoplot(zeros(EEG.nbchan,1),EEG.chanlocs,'electrodes','on','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');

% EEG128
subplot(154)

EEG = layout_data(5);

topoplot(zeros(EEG.nbchan+1,1),EEG.chanlocs,'electrodes','on','emsize',30)
set(findobj(gca,'type','patch'),'facecolor','w');
plotlines = findobj(gca,'type','line');
plotlines(1).XData(1:end-1) = [];
plotlines(1).YData(1:end-1) = [];
plotlines(1).ZData(1:end-1) = [];
plotlines(1).Color = [0.9 0 0];

EEG.chanlocs(end) = [];

topoplot(zeros(EEG.nbchan,1),EEG.chanlocs,'electrodes','on','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');

% EEG157
subplot(155)

EEG = layout_data(6);

topoplot(zeros(EEG.nbchan+1,1),EEG.chanlocs,'electrodes','on','emsize',30)
set(findobj(gca,'type','patch'),'facecolor','w');
plotlines = findobj(gca,'type','line');
plotlines(1).XData(1:end-1) = [];
plotlines(1).YData(1:end-1) = [];
plotlines(1).ZData(1:end-1) = [];
plotlines(1).Color = [0.9 0 0];

EEG.chanlocs(end) = [];

% scalp channels
topoplot(zeros(EEG.nbchan,1,1),EEG.chanlocs,'electrodes','on','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');
plotlines = findobj(gca,'type','line');
plotlines(1).XData([129:156]) = [];
plotlines(1).YData([129:156]) = [];
plotlines(1).ZData([129:156]) = [];

% add different markers for neck channels
topoplot(zeros(EEG.nbchan,1,1),EEG.chanlocs,'electrodes','on','emsize',5)
set(findobj(gca,'type','patch'),'facecolor','w');
plotlines = findobj(gca,'type','line');
plotlines(1).XData([1:128 157]) = [];
plotlines(1).YData([1:128 157]) = [];
plotlines(1).ZData([1:128 157]) = [];
plotlines(1).Marker = 's';
plotlines(1).MarkerFaceColor = 'k';

set(gcf,'color','w');

%% export figure
if do_export
	export_fig_all('..\analysis\plots\paradigm\density_layouts_horizontal_reviewed')
end

%% plot comparison topographies for 16 channel density levels

load('plot_data\layout_data')

figure(3);clf;set(gcf,'position',[196 648 644 330])

% EEG 15 = dorsal channel layout
subplot(121)

EEG = layout_data(1);

topoplot(zeros(EEG.nbchan+1,1),EEG.chanlocs,'electrodes','on','emsize',30)

title({'Dorsal Layout',['Mean: [' num2str(round(EEG.chanlocs(end).X,1)) ', ' ...
	num2str(round(EEG.chanlocs(end).Y,1)) ', ' num2str(round(EEG.chanlocs(end).Z,1)) '] mm']})

set(findobj(gca,'type','patch'),'facecolor','w');
plotlines = findobj(gca,'type','line');
plotlines(1).XData(1:end-1) = [];
plotlines(1).YData(1:end-1) = [];
plotlines(1).ZData(1:end-1) = [];
plotlines(1).Color = [0.9 0 0];

EEG.chanlocs(end) = [];

topoplot(zeros(EEG.nbchan,1),EEG.chanlocs,'electrodes','on','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');

% EEG 16 = whole head layout
subplot(122)

EEG = layout_data(2);

topoplot(zeros(EEG.nbchan+1,1),EEG.chanlocs,'electrodes','on','emsize',30)

title({'Whole-Head Layout',['Mean: [' num2str(round(EEG.chanlocs(end).X,1)) ', ' ...
	num2str(round(EEG.chanlocs(end).Y,1)) ', ' num2str(round(EEG.chanlocs(end).Z,1)) '] mm']})

set(findobj(gca,'type','patch'),'facecolor','w');
plotlines = findobj(gca,'type','line');
plotlines(1).XData(1:end-1) = [];
plotlines(1).YData(1:end-1) = [];
plotlines(1).ZData(1:end-1) = [];
plotlines(1).Color = [0.9 0 0];

EEG.chanlocs(end) = [];

topoplot(zeros(EEG.nbchan,1),EEG.chanlocs,'electrodes','on','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');

set(gcf,'color','w');

%% export figure
if do_export
	export_fig_all('..\analysis\plots\paradigm\density_layouts_16_comparison')
end

%% load for example topoplots, s2 had some nice ones

if load_original_data
	
	EEG = pop_loadset('filename','s-2_condition-joystick_density-128_highpass-75_fixedOrder_final_unfiltered_lite.set','filepath','..\\data\\SR\\AMICAs\\same_length2\\2\\');
	
	clear topography_data
	topography_data.icawinv = EEG.icawinv;
	topography_data.chanlocs = EEG.chanlocs;
	save('plot_data\topography_data','topography_data')
	
end

%%
load('plot_data\topography_data')
EEG = topography_data;

figure(4);clf
subplot(151)
topoplot(EEG.icawinv(:,24),EEG.chanlocs,'electrodes','off','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');
subplot(152)
topoplot(EEG.icawinv(:,1),EEG.chanlocs,'electrodes','off','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');
subplot(153)
topoplot(EEG.icawinv(:,17),EEG.chanlocs,'electrodes','off','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');
subplot(154)
topoplot(EEG.icawinv(:,121),EEG.chanlocs,'electrodes','off','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');
subplot(155)
topoplot(EEG.icawinv(:,100),EEG.chanlocs,'electrodes','off','emsize',12)
set(findobj(gca,'type','patch'),'facecolor','w');
set(gcf,'color','w');

set(gcf,'position',[498 347 1219 457])

%%
if do_export
	export_fig_all('..\analysis\plots\paradigm\ICLabel_examples_horizontal')
end

%% plot parietal component

if load_original_data
	
	EEG = pop_loadset('filename','s-6_condition-joystick_density-128_highpass-125_fixedOrder_final_unfiltered_lite.set','filepath','..\\data\\SR\\AMICAs\\same_length2\\6\\');
	
	clear parietal_data
	parietal_topography_data.icawinv = EEG.icawinv;
	parietal_topography_data.chanlocs = EEG.chanlocs;
	save('plot_data\parietal_topography_data','parietal_topography_data')
	
end

%%

load('plot_data\parietal_topography_data')
EEG = parietal_topography_data;

figure(5);clf
topoplot(EEG.icawinv(:,9),EEG.chanlocs,'electrodes','off')
set(findobj(gca,'type','patch'),'facecolor','w');
set(gcf,'color','w');

set(gcf,'position',[932 617 1219 186])

%%
if do_export
	export_fig_all('..\analysis\plots\paradigm\parietal_pattern')
end