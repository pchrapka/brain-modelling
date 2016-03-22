%% exp07_beamform_eeg_mmn_contrast_plots

%% Run the analysis script
exp07_beamform_eeg_mmn_contrast

%% Plots
plot_eegprepost(eeg_prepost,'timelock',false,'preprocessed',false);
plot_beamformercontrast(bf_contrast,...
    'beamformer',true,'moment',false,'save',true);