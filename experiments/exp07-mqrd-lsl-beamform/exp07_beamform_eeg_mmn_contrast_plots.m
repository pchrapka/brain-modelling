%% exp07_beamform_eeg_mmn_contrast_plots

%% Run the analysis script
exp07_beamform_eeg_mmn_contrast

%% EEG plots
plot_preprocessed = false;
plot_timelock = false;

if plot_preprocessed
    type = 'all';
    switch type
        case 'all'
            eegObj = eeg_prepost;
        case 'pre'
            eegObj = eeg_prepost.pre;
        case 'post'
            eegObj = eeg_prepost.post;
    end
    cfg = [];
    cfg.channel = 'Cz';
    eegObj.plot_data('preprocessed',cfg)
end

if plot_timelock
    %type = 'post';
    %type = 'pre';
    type = 'all';
    switch type
        case 'all'
            eegObj = eeg_prepost;
        case 'pre'
            eegObj = eeg_prepost.pre;
        case 'post'
            eegObj = eeg_prepost.post;
    end
    cfg = [];
    %cfg.channel = 'Cz';
    eegObj.plot_data('timelock',cfg)
end

%% Beamformer plots
plot_save = true;
plot_bf = true;
plot_moment = false; % no moment in contrast

if plot_save
    cfgsave = [];
    cfgsave.out_dir = fullfile(pwd,'img');
    
    if ~exist(cfgsave.out_dir,'dir')
        mkdir(cfgsave.out_dir);
    end
end

if plot_bf
    % figure;
    % bf.plot({'brain','skull','scalp','fiducials'});
    
    options = [];
    %options.funcolorlim = [-0.2 0.2];
    options.funcolormap = 'jet';
    
    %figure;
    %bf_contrast.plot_scatter([]);
    bf_contrast.plot_anatomical('method','slice','options',options);
    save_fig(cfgsave, 'mmn-slice-contrast-no-mask', plot_save);
    bf_contrast.plot_anatomical('method','ortho','options',options);
    save_fig(cfgsave, 'mmn-ortho-contrast-no-mask', plot_save);
    bf_contrast.plot_anatomical('method','slice','options',options,'mask','max');
    save_fig(cfgsave, 'mmn-slice-contrast-mask', plot_save);
    bf_contrast.plot_anatomical('method','ortho','options',options,'mask','max');
    save_fig(cfgsave, 'mmn-ortho-contrast-mask', plot_save);
    
    if plot_moment
        figure;
        bf_contrast.plot_moment('2d-all');
        figure;
        bf_contrast.plot_moment('2d-top');
        figure;
        bf_contrast.plot_moment('1d-top');
    end
    
    options = [];
    %options.funcolorlim = [-0.2 0.2];
    options.funcolormap = 'jet';
    
    %figure;
    %bf_contrast.pre.plot_scatter([]);
    bf_contrast.pre.plot_anatomical('method','slice','options',options);
    save_fig(cfgsave, 'pre-slice-contrast-no-mask', plot_save);
    bf_contrast.pre.plot_anatomical('method','ortho','options',options);
    save_fig(cfgsave, 'pre-ortho-contrast-no-mask', plot_save);
    
    if plot_moment
        figure;
        bf_contrast.pre.plot_moment('2d-all');
        figure;
        bf_contrast.pre.plot_moment('2d-top');
        figure;
        bf_contrast.pre.plot_moment('1d-top');
    end
    
    %figure;
    %bf_contrast.post.plot_scatter([]);
    bf_contrast.post.plot_anatomical('method','slice','options',options);
    save_fig(cfgsave, 'post-slice-contrast-no-mask', plot_save);
    bf_contrast.post.plot_anatomical('method','ortho','options',options);
    save_fig(cfgsave, 'post-ortho-contrast-no-mask', plot_save);
    
    if plot_moment
        figure;
        bf_contrast.post.plot_moment('2d-all');
        figure;
        bf_contrast.post.plot_moment('2d-top');
        figure;
        bf_contrast.post.plot_moment('1d-top');
    end
end