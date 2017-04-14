%% check_pdc_bootstrap_single_channel_est
% checks correlation between single channel reflection coefficient
% estimates
%
%   goal: can similar time-varying coefficients produce strong spurious
%   PDC?

dir_project = '/home.old/chrapkpk/Documents/projects/brain-modelling/';

% normalization - allchannels
% dir_data = fullfile('analysis','pdc-analysis','output','std-s03-10',...
%     'aal-coarse-19-outer-nocer-plus2',...
%     'lf-sources-ch12-trials100-samplesall-normallchannels-envyes-for-filter',...
%     'MCMTLOCCD_TWL4-T20-C12-P11-lambda=0.9900-gamma=1.000e-05-bootstrap-estimate_ind_channels',...
%     'channels-ind');

% normalization - eachchannel
dir_data = fullfile('analysis','pdc-analysis','output','std-s03-10',...
    'aal-coarse-19-outer-nocer-plus2',...
    'lf-sources-ch12-trials100-samplesall-normeachchannel-envyes-for-filter',...
    'MCMTLOCCD_TWL4-T20-C12-P11-lambda=0.9900-gamma=1.000e-05-bootstrap-estimate_ind_channels',...
    'channels-ind');
filter_file = 'MCMTLOCCD_TWL4-T20-C1-P11-lambda=0.9900-gamma=1.000e-05.mat';

nchannels = 12;
data_all = [];
for i=1:nchannels
    dir_ch = sprintf('ch%d',i);
    file_name = fullfile(dir_project, dir_data, dir_ch, filter_file);
    data = loadfile(file_name);
    
    % data should be [samples order]
    if i==1
        data_all = data.estimate.Kf;
    else
        data_all(:,:,i) = data.estimate.Kf;
    end
end
data_all = permute(data_all,[1 3 2]);

% need [samples channels order]
plot_covariance_order(data_all);