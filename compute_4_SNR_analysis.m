if ~exist('ALLEEG','var')
	eeglab
end
addpath('P:\Marius\toolboxes\export_fig') %https://de.mathworks.com/matlabcentral/fileexchange/23629-export_fig


start_event = 'start_outward_rotation';
P3start = 250;
P3end = 450;
prestim_noise_start = -500;
prestim_noise_end = 0;
epoch_bounds = [-0.6  1.2];
baseline_bounds = [-600     0];
subjects = [1:7 9:20];

filter_freqs = [0 0.5:0.25:1.5 1.75:0.5:3.25 4.25];
classifier_versions = {'default', 'lite'};

fallback_brain = [];

all_channels = [15 16 32 64 128 157]; % using 15 as a proxy for the dorsal 16 channel layout

%%

for subject = subjects
	for filter_freq = filter_freqs
		i_filter_freq = find(filter_freq == filter_freqs);
		for i_classifier_version = 1:length(classifier_versions)
			classifier_version = classifier_versions{i_classifier_version};
			
			EEG_joystick = []; EEG_steamvr = [];
			
			% load datasets of all densities and both conditions
			EEG_joystick = pop_loadset('filename',...
				{['s-' num2str(subject) '_condition-joystick_density-15_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-joystick_density-16_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-joystick_density-32_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-joystick_density-64_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-joystick_density-128_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-joystick_density-157_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set']},...
				'filepath',['..\data\SR\AMICAs\same_length2\' num2str(subject) '\']);
			
			
			EEG_steamvr = pop_loadset('filename',...
				{['s-' num2str(subject) '_condition-steamvr_density-15_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-steamvr_density-16_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-steamvr_density-32_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-steamvr_density-64_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-steamvr_density-128_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set'],...
				['s-' num2str(subject) '_condition-steamvr_density-157_highpass-' num2str(filter_freq*100) '_fixedOrder_final_unfiltered_' classifier_version '.set']},...
				'filepath',['..\data\SR\AMICAs\same_length2\' num2str(subject) '\']);
			
			%%
			
			for i_joy = 1:length(EEG_joystick)
				
				for i_event = 1:length(EEG_joystick(i_joy).event)
					
					% to account for wireless EEG lag of 100ms (25 samples)
					% we need to move events, see Gramann et al (2018)
					EEG_joystick(i_joy).event(i_event).latency = ...
						EEG_joystick(i_joy).event(i_event).latency + 25;
					
				end
				
			end
			
			for i_steamvr = 1:length(EEG_steamvr)
				
				for i_event = 1:length(EEG_steamvr(i_steamvr).event)
					
					% to account for wireless EEG lag of 100ms (25 samples)
					% we need to move events, see Gramann et al (2018)
					EEG_steamvr(i_steamvr).event(i_event).latency = ...
						EEG_steamvr(i_steamvr).event(i_event).latency + 25;
					
				end
				
			end
			
			%% find n for both conditions
			
			EEG_joystick_ntest = pop_epoch( EEG_joystick(1), {  start_event  }, epoch_bounds, 'newname', 'Merged datasets resampled epochs', 'epochinfo', 'yes');
			EEG_joystick_ntest = pop_rmbase( EEG_joystick_ntest, baseline_bounds);
			n_joystick = size(EEG_joystick_ntest.data,3);
			EEG_steamvr_ntest = pop_epoch( EEG_steamvr(1), {  start_event  }, epoch_bounds, 'newname', 'Merged datasets resampled epochs', 'epochinfo', 'yes');
			EEG_steamvr_ntest = pop_rmbase( EEG_steamvr_ntest, baseline_bounds);
			n_steamvr = size(EEG_steamvr_ntest.data,3);
			
			n_to_use = min(n_joystick,n_steamvr);
			epochs_joystick = 1:n_to_use; 
			epochs_steamvr = 1:n_to_use; 
			
			P3_idx = find(EEG_joystick_ntest.times>=P3start,1,'first'):find(EEG_joystick_ntest.times<P3end,1,'last');
			prestim_noise_idx = find(EEG_joystick_ntest.times>=prestim_noise_start,1,'first'):find(EEG_joystick_ntest.times<prestim_noise_end,1,'last');
			
			%% compute ERPs and SNRs
			
			this_fig = figure(3); set(gcf, 'color','w'); clf; set(gcf, 'position', [182 64 1900 1275]),
			
			% joystick uncleaned
			subplot(length(EEG_joystick)+1,2,1)
			
			EEG = EEG_joystick(1);
			
			POz_idx = find(strcmp({EEG.chanlocs.labels},'r23'))
			
			EEG = pop_epoch( EEG, {  start_event  }, epoch_bounds, 'newname', 'Merged datasets resampled epochs', 'epochinfo', 'yes');
			EEG = pop_rmbase( EEG, baseline_bounds);
			
			POz_data = squeeze(EEG.data(POz_idx,:,epochs_joystick));
			ERP_POz = squeeze(mean(POz_data,2));
			
			P3_signal = mean(ERP_POz(P3_idx));
			prestim_noise = std(ERP_POz(prestim_noise_idx));
			ERP_SNR = P3_signal/prestim_noise;
			
			
			plot(EEG.times,ERP_POz)
			
			vline(0,'k');
			vline(prestim_noise_start,'r');
			vline(prestim_noise_end,'r');
			vline(P3start,'g');
			vline(P3end,'g');
			hline(0,'k');
			
			title({['S' num2str(subject) ', ' num2str(filter_freq*100)...
				'Hz, JoyR uncleaned, event=' start_event ', n=' num2str(length(epochs_joystick))]
				['signal = ' num2str(P3_signal)...
				', noise = ' num2str(prestim_noise)]
				['SNR = ' num2str(ERP_SNR)]})
			
			this_data.s = subject;
			this_data.filter_freq = filter_freq;
			this_data.start_event = start_event;
			this_data.n_epochs = n_to_use;
			
			this_data.ERPs(1,1,:) = ERP_POz;
			this_data.P3_signal(1,1) = P3_signal;
			this_data.prestim_noise(1,1) = prestim_noise;
			this_data.ERP_SNRs(1,1) = ERP_SNR;
			
			
			% physR uncleaned
			subplot(length(EEG_joystick)+1,2,2)
			
			EEG = EEG_steamvr(1);
			POz_idx = find(strcmp({EEG.chanlocs.labels},'r23'))
			
			EEG = pop_epoch( EEG, {  start_event  }, epoch_bounds, 'newname', 'Merged datasets resampled epochs', 'epochinfo', 'yes');
			EEG = pop_rmbase( EEG, baseline_bounds);
			
			POz_data = squeeze(EEG.data(POz_idx,:,epochs_steamvr));
			ERP_POz = squeeze(mean(POz_data,2));
			
			P3_signal = mean(ERP_POz(P3_idx));
			prestim_noise = std(ERP_POz(prestim_noise_idx));
			ERP_SNR = P3_signal/prestim_noise;
			
			plot(EEG.times,ERP_POz)
			
			vline(0,'k');
			vline(prestim_noise_start,'r');
			vline(prestim_noise_end,'r');
			vline(P3start,'g');
			vline(P3end,'g');
			hline(0,'k');
			
			title({['S' num2str(subject) ', ' num2str(filter_freq*100)...
				'Hz, PhysR uncleaned, event=' start_event ', n=' num2str(length(epochs_steamvr))]
				['signal = ' num2str(P3_signal)...
				', noise = ' num2str(prestim_noise)]
				['SNR = ' num2str(ERP_SNR)]})
			
			this_data.ERPs(2,1,:) = ERP_POz;
			this_data.P3_signal(2,1) = P3_signal;
			this_data.prestim_noise(2,1) = prestim_noise;
			this_data.ERP_SNRs(2,1) = ERP_SNR;
			
			% cleaned joystick
			for EEG_idx = 1:length(EEG_joystick)
				
				subplot(length(EEG_joystick)+1,2,1+EEG_idx*2)
				EEG = EEG_joystick(EEG_idx);
				POz_idx = find(strcmp({EEG.chanlocs.labels},'r23'));
				
				nonbrain_ICs = find(EEG.etc.ic_classification.ICLabel.classifications(:,1) ~= max(EEG.etc.ic_classification.ICLabel.classifications,[],2));
				n_brain_ICs = size(EEG.icaweights,1) - length(nonbrain_ICs);
				
				if n_brain_ICs == 0
					% use the highest brain probability IC as the only
					% brain IC if no brain ICs were found
					
					fallback_brain(subject,1,i_filter_freq,i_classifier_version,EEG_idx) = 1;
					
					warndlg(['subject: ' num2str(subject) ', movement: ' num2str(1) ', i_filter_freq: '...
						num2str(i_filter_freq) ', i_classifier_version: ' num2str(i_classifier_version)...
						', EEG_idx: ' num2str(EEG_idx) ', only ' num2str(fallback_brain(subject,1,i_filter_freq,i_classifier_version,EEG_idx))...
						' brain ICs!'])
					
					% there is absolutely a better way to do this but I'm lazy
					% right now, this works, don't judge me!
					sorted_brain_probs = sort(EEG.etc.ic_classification.ICLabel.classifications(:,1),'descend');
					
					max_prob_brain_IC = find(EEG.etc.ic_classification.ICLabel.classifications(:,1)==...
						sorted_brain_probs(1));
					
					nonbrain_ICs(nonbrain_ICs == max_prob_brain_IC) = [];
					
				end
				
				
				EEG = pop_subcomp( EEG, nonbrain_ICs, 0);
				
				EEG = pop_epoch( EEG, {  start_event  }, epoch_bounds, 'newname', 'Merged datasets resampled epochs', 'epochinfo', 'yes');
				EEG = pop_rmbase( EEG, baseline_bounds);
				
				POz_data = squeeze(EEG.data(POz_idx,:,epochs_joystick));
				ERP_POz = squeeze(mean(POz_data,2));
				
				P3_signal = mean(ERP_POz(P3_idx));
				prestim_noise = std(ERP_POz(prestim_noise_idx));
				ERP_SNR = P3_signal/prestim_noise;
				
				plot(EEG.times,ERP_POz)
				
				vline(0,'k');
				vline(prestim_noise_start,'r');
				vline(prestim_noise_end,'r');
				vline(P3start,'g');
				vline(P3end,'g');
				hline(0,'k');
				
				title({['JoyR, channels: ' num2str(all_channels(EEG_idx))...
					', brain ICs: ' num2str(n_brain_ICs) ', used: ' num2str(size(EEG.icaweights,1))]
					['signal = ' num2str(P3_signal)...
					', noise = ' num2str(prestim_noise)]
					['SNR = ' num2str(ERP_SNR)]})
				
				this_data.ERPs(1,1+EEG_idx,:) = ERP_POz;
				this_data.P3_signal(1,1+EEG_idx) = P3_signal;
				this_data.prestim_noise(1,1+EEG_idx) = prestim_noise;
				this_data.ERP_SNRs(1,1+EEG_idx) = ERP_SNR;
				
			end
			
			% cleaned steamvr
			for EEG_idx = 1:length(EEG_steamvr)
				
				subplot(length(EEG_steamvr)+1,2,2+EEG_idx*2);
				
				EEG = EEG_steamvr(EEG_idx);
				POz_idx = find(strcmp({EEG.chanlocs.labels},'r23'));
				
				nonbrain_ICs = find(EEG.etc.ic_classification.ICLabel.classifications(:,1) ~= max(EEG.etc.ic_classification.ICLabel.classifications,[],2));
				n_brain_ICs = size(EEG.icaweights,1) - length(nonbrain_ICs);
				
				if n_brain_ICs == 0
					% use the highest brain probability IC as the only
					% brain IC if no brain ICs were found
					
					fallback_brain(subject,2,i_filter_freq,i_classifier_version,EEG_idx) = 1;
					
					warndlg(['subject: ' num2str(subject) ', movement: ' num2str(2) ', i_filter_freq: '...
						num2str(i_filter_freq) ', i_classifier_version: ' num2str(i_classifier_version)...
						', EEG_idx: ' num2str(EEG_idx) ', only ' num2str(fallback_brain(subject,1,i_filter_freq,i_classifier_version,EEG_idx))...
						' brain ICs!'])
					
					% there is absolutely a better way to do this but I'm lazy
					% right now, this works, don't judge me!
					sorted_brain_probs = sort(EEG.etc.ic_classification.ICLabel.classifications(:,1),'descend');
					
					max_prob_brain_IC = find(EEG.etc.ic_classification.ICLabel.classifications(:,1)==...
						sorted_brain_probs(1));
					
					nonbrain_ICs(nonbrain_ICs == max_prob_brain_IC) = [];
					
				end
				
				EEG = pop_subcomp( EEG, nonbrain_ICs, 0);
				
				EEG = pop_epoch( EEG, {  start_event  }, epoch_bounds, 'newname', 'Merged datasets resampled epochs', 'epochinfo', 'yes');
				EEG = pop_rmbase( EEG, baseline_bounds);
				
				POz_data = squeeze(EEG.data(POz_idx,:,epochs_steamvr));
				ERP_POz = squeeze(mean(POz_data,2));
				
				P3_signal = mean(ERP_POz(P3_idx));
				prestim_noise = std(ERP_POz(prestim_noise_idx));
				ERP_SNR = P3_signal/prestim_noise;
				
				plot(EEG.times,ERP_POz)
				
				vline(0,'k');
				vline(prestim_noise_start,'r');
				vline(prestim_noise_end,'r');
				vline(P3start,'g');
				vline(P3end,'g');
				hline(0,'k');
				
				title({['PhysR, channels: ' num2str(all_channels(EEG_idx))...
					', brain ICs: ' num2str(n_brain_ICs) ', used: ' num2str(size(EEG.icaweights,1))]
					['signal = ' num2str(P3_signal)...
					', noise = ' num2str(prestim_noise)]
					['SNR = ' num2str(ERP_SNR)]})
				
				this_data.ERPs(2,1+EEG_idx,:) = ERP_POz;
				this_data.P3_signal(2,1+EEG_idx) = P3_signal;
				this_data.prestim_noise(2,1+EEG_idx) = prestim_noise;
				this_data.ERP_SNRs(2,1+EEG_idx) = ERP_SNR;
				
			end
			
			%% save data and figure
			
			mkdir(['..\analysis\SNR\' num2str(subject) ])
			save(['..\analysis\SNR\' num2str(subject) '\s-' num2str(subject)...
				'_highpass-' num2str(filter_freq*100) '_' classifier_version '_SNR-data'],...
				'this_data')
			export_fig_all(['..\analysis\SNR\' num2str(subject) '\s-' num2str(subject)...
				'_highpass-' num2str(filter_freq*100) '_' classifier_version '_SNR-data'],...
				this_fig,1)
			
		end
	end
end

save('fallback_brain','fallback_brain')