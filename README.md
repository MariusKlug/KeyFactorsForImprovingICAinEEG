# Identifying key factors for improving ICA-based decomposition of EEG data in mobile and stationary experiments 

[https://www.biorxiv.org/content/10.1101/2020.06.02.129213v1](https://www.biorxiv.org/content/10.1101/2020.06.02.129213v1)

### Marius Klug, Klaus Gramann

Corresponding author: Marius Klug, Biopsychology and Neuroergonomics, TU Berlin, 10623, Berlin, Germany:

**Email:** marius.s.klug@gmail.com, marius.klug@tu-berlin.de

**Researchgate:** https://www.researchgate.net/profile/Marius_Klug

**Twitter:** https://twitter.com/marius_s_klug


### Abstract
Recent developments in EEG hardware and analyses approaches allow for recordings in both stationary and mobile settings. Irrespective of the experimental setting, EEG recordings are contaminated with noise that has to be removed before the data can be functionally interpreted. Independent component analysis (ICA) is a commonly used tool to remove artifacts such as eye movement, muscle activity, and external noise from the data and to analyze activity on the level of EEG effective brain sources. While the effectiveness of filtering the data as one key preprocessing step to improve the decomposition has been investigated previously, no study thus far compared the different requirements of mobile and stationary experiments regarding the preprocessing for ICA decomposition. We thus evaluated how movement in EEG experiments, the number of channels, and the high-pass filter cutoff during preprocessing influence the ICA decomposition. We found that for commonly used settings (stationary experiment, 64 channels, 0.5 Hz filter), the ICA results are acceptable. However, high-pass filters of up to 2 Hz cutoff frequency should be used in mobile experiments, and more channels require a higher filter to reach an optimal decomposition. Fewer brain ICs were found in mobile experiments, but cleaning the data with ICA proved to be important and functional even with low/density setups. Based on the results, we provide guidelines for different experimental settings that improve the ICA decomposition.

### Keywords
Electroencephalogram (EEG), Artifact removal, Muscle artifacts, Blind source separation (BSS), Independent component analysis (ICA), Filtering 

# Usage
Provided with these scripts is a set of final extracted features to plot, but not the original dataset. The processing code can not be run without the original dataset but is provided for inspection. The plotting code can be run when the following additional packages are installed:

* **EEGLAB:** https://sccn.ucsd.edu/eeglab/download.php
* **Colormaps:** https://de.mathworks.com/matlabcentral/fileexchange/30564-othercolor, https://github.com/ZedThree/nemorb_matlab/blob/master/diverging_map.m
* **HLine and VLine Helper:** https://de.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline
* **Export figures:** https://de.mathworks.com/matlabcentral/fileexchange/23629-export_fig




