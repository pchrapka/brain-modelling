%% paper_plot_pdc_distr_with_surrogate_threshold

params = data_beta_config();
dir_root = params.data_dir;

dir_data = fullfile(dir_root,'output','std-s03-10',...
    'aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata');

% % get data size
% file_data = 'MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4.mat';
% file_name = fullfile(dir_data,file_data);
% data = loadfile(file_name);
% [nsamples,nchannels,~,nfreqs] = size(data.pdc);

idx_channel_in = 1; % temporal
idx_channel_out = 6; % auditory
idx_sample = 656;
% idx_sample = 300;

plot_params = [];
pdc_params = 'pdc-dynamic-diag-f2048-41-ds4';

k=1;
plot_params(k).stub_filter = 'MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05';
plot_params(k).perm_stat = '-p1';
plot_params(k).perm_surrogate = '-p3';
plot_params(k).slug_name = 'trials20';
k = k+1;

plot_params(k).stub_filter = 'MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-04';
plot_params(k).perm_stat = '-p1';
plot_params(k).perm_surrogate = '-p1';
plot_params(k).slug_name = 'trials20-1e-4';
k = k+1;

plot_params(k).stub_filter = 'MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05';
plot_params(k).perm_stat = '-p1';
plot_params(k).perm_surrogate = '-p1';
plot_params(k).slug_name = 'trials100';
k = k+1;

for k=1:length(plot_params)
    stub_filter = plot_params(k).stub_filter;
    perm_stat = plot_params(k).perm_stat;
    perm_surrogate = plot_params(k).perm_surrogate;
    
    file_name_std = fullfile(dir_data,...
        [stub_filter perm_stat '-removed-' pdc_params '-std100.mat']);
    file_name_mean = fullfile(dir_data,...
        [stub_filter perm_stat '-removed-' pdc_params '-mean100.mat']);
    
    file_name_surrogate_ns = fullfile(dir_data,...
        [stub_filter perm_surrogate '-removed-surrogate-estimate_stationary_ns'],...
        [pdc_params '-sig-n100-alpha0.05.mat']);
    file_name_surrogate_ind = fullfile(dir_data,...
        [stub_filter perm_surrogate '-removed-surrogate-estimate_ind_channels'],...
        [pdc_params '-sig-n100-alpha0.05.mat']);
    
    plot_pdc_distr_with_surrogate_threshold(file_name_std, file_name_mean,...
        'surrogate_files', {file_name_surrogate_ns, file_name_surrogate_ind},...
        'surrogate_legend', {'threshold - stationary','threshold - no coupling'},...
        'freq_step', 0.5,...
        'freq_max', 10,...
        'idx_sample', idx_sample,...
        'idx_channel_in', idx_channel_in,...
        'idx_channel_out', idx_channel_out,...
        'tag', plot_params(k).slug_name);

end