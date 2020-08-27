
switch subject
	
	%%% subject 1
	case 1
		
		% r21: adjacent are r18, r20, r22, r26; can be interpolated in
		% polar values (polar assumes a spherical head, carthesian XYZ might be a little
		% under the scalp surface after interpolation. polar is hence
		% theoretically better but it has to be inspected because it's
		% sometimes far off!)
		% r18 = [51.3796  0.098719];
		% r20 = [103.3013 0.076907];
		% r22 = [67.626 0.17049];
		% r26 = [101.4057 0.15783];
		% r21 = mean([r20; r22; r26; r18],1)
		
		EEG=pop_chanedit(EEG, 'changefield',{85 'theta' '80.9281'},'changefield',{85 'radius' '0.1260'},'convert',{'topo2all'});
		[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
		EEG = eeg_checkset( EEG );
		
		EEG.etc.interpolated_locations.location = 'r21';
		EEG.etc.interpolated_locations.from = {'r20' 'r22' 'r26' 'r18'};
		EEG.etc.interpolated_locations.method = 'topo2all';
		
		%%% subject 3:
	case 3
		
		% r30: adjacent are r27, r29, r31, w21; can be interpolated in polar
		% r27 = [101.5161 0.2575];
		% r29 = [129.2299 0.3031];
		% r31 = [96.099 0.32382];
		% w21 = [117.8316 0.37519];
		% r30 = mean([r27; r29; r31; w21],1)
		
		EEG=pop_chanedit(EEG, 'changefield',{94 'theta' '111.1691'},'changefield',{94 'radius' '0.3149'},'convert',{'topo2all'});
		[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
		EEG = eeg_checkset( EEG );
		
		EEG.etc.interpolated_locations.location = 'r30';
		EEG.etc.interpolated_locations.from = {'r27' 'r29' 'r31' 'w21'};
		EEG.etc.interpolated_locations.method = 'topo2all';
		
		% data cables had been mixed
		[ALLEEG, EEG, CURRENTSET] = bemobil_unmix_electrode_mixups( EEG , ALLEEG, CURRENTSET, [1:64; 33:64 1:32], []);
		
		%%% subject 4:
	case 4
		
		% left eye frontal electrodes physically misplaced
		[ALLEEG, EEG, CURRENTSET] = bemobil_unmix_electrode_mixups( EEG , ALLEEG, CURRENTSET, [10 12 14 16; 12 14 16 10], [10 12 14 16; 12 14 16 10]);
		
		%%% subject 8:
	case 8
		
		% data cables had been mixed
		[ALLEEG, EEG, CURRENTSET] = bemobil_unmix_electrode_mixups( EEG , ALLEEG, CURRENTSET, [1:64; 33:64 1:32], []);
		
		%%% subject 9:
	case 9
		
		% n19: adjacent are n12, n13, n18, n20, n25, n26; neck has to be
		% interpolated in XYZ
		% n12 = [-105.607 -4.592 -23.81];
		% n13 = [-94.891 -33.141 -29.122];
		% n18 = [-110.099 14.004 -31.48];
		% n20 = [-94.025 -44.157 -44.663];
		% n25 = [-123.142 -4.121 -42.436];
		% n26 = [-116.396 -35.635 -48.902];
		% n19 = mean([n12; n13; n18; n20; n25; n26],1)
		
		EEG=pop_chanedit(EEG, 'changefield',{147 'X' '-107.3600'},'changefield',{147 'Y' '-17.9403'},'changefield',{147 'Z' '-36.7355'},'convert',{'cart2all'});
		[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
		EEG = eeg_checkset( EEG );
		
		EEG.etc.interpolated_locations.location = 'n19';
		EEG.etc.interpolated_locations.from = {'n12' 'n13' 'n18' 'n20' 'n25' 'n26'};
		EEG.etc.interpolated_locations.method = 'cart2all';
		
		%%% subject 12:
	case 12
		
		% r29 is missing, located at position of 30, which is located at position
		% of 31, which is located at 32, double with 32. shit. approach:
		% interpolate 31 at location of 29, then interchange locations back to
		% correct. Adjacent to (new and incorrect at first) r31 are r26, r28, r29,
		% w20; polar interpolation is weird, cartesian is used
		% r26 = [-41.338 -74.413 88.987];
		% r28 = [-76.935 -51.122 78.529];
		% r29 = [-40.196 -80.661 58.764];
		% w20 = [-71.558 -63.023 43.157];
		% r31 = mean([r26; r28; r29; w20],1);
		
		EEG=pop_chanedit(EEG, 'changefield',{95 'X' '-57.5067'},'changefield',{95 'Y' '-67.3047'}, 'changefield',{95 'Z' '67.3593'},'convert',{'cart2all'});
		[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
		EEG = eeg_checkset( EEG );
		
		EEG.etc.interpolated_locations.location = 'r31';
		EEG.etc.interpolated_locations.from = {'r26' 'r28' 'r29' 'w20'};
		EEG.etc.interpolated_locations.method = 'cart2all';
		
		% some electrode location digitization mixed up
		[ALLEEG, EEG, CURRENTSET] = bemobil_unmix_electrode_mixups( EEG , ALLEEG, CURRENTSET, [], [93 94 95; 95 93 94]);
		
		%%% subject 13:
	case 13
		
		% right eye frontal electrodes physically misplaced
		[ALLEEG, EEG, CURRENTSET] = bemobil_unmix_electrode_mixups( EEG , ALLEEG, CURRENTSET, [22 32; 32 22], [22 32; 32 22]);
		
		%%% subject 15:
	case 15
		
		% w22 is wrong, adjacent are w9 and w23; has to be interpolated in XYZ
		% because over the 180 boarder (and is weird then)
		% w9 = [-96.002 10.727 25.247];
		% w23 = [-94.697 -29.176 23.551];
		% w22 = mean([w9; w23],1)
		
		EEG=pop_chanedit(EEG,'changefield',{118 'X' '-95.3495'},'changefield',{118 'Y' '-9.2245'},'changefield',{118 'Z' '24.3990'},'convert',{'cart2all'});
		[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
		EEG = eeg_checkset( EEG );
		
		EEG.etc.interpolated_locations.location = 'w22';
		EEG.etc.interpolated_locations.from = {'w9' 'w23'};
		EEG.etc.interpolated_locations.method = 'cart2all';
		
		%%% subject 15:
	case 17
		
		%             r21: adjacent are r20, r22, r18, r26; can be interpolated in polar
		r20 = [144.3636 0.1851];
		r22 = [103.6495 0.18567];
		r18 = [126.4892 0.11861];
		r26 = [125.8998 0.24653];
		r30 = mean([r20; r22; r18; r26],1)
		
		EEG=pop_chanedit(EEG, 'changefield',{85 'theta' '125.1005'},'changefield',{85 'radius' '0.1840'},'convert',{'topo2all'});
		[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
		EEG = eeg_checkset( EEG );
		
		EEG.etc.interpolated_locations.location = 'r21';
		EEG.etc.interpolated_locations.from = {'r20' 'r22' 'r18' 'r26'};
		EEG.etc.interpolated_locations.method = 'topo2all';
		
end