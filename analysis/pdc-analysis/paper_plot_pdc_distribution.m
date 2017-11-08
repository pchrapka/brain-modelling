%% paper_plot_pdc_distribution

params = data_beta_config();
dir_root = params.data_dir;
% '/home.old','chrapkpk','Documents','projects','brain-modelling','analysis','pdc-analysis',

dir_data = fullfile(dir_root,'output','std-s03-10',...
    'aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata');

npermutations = 1;%100;
for i=1:npermutations
    file_data = sprintf('MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p%d-removed-pdc-dynamic-diag-f2048-41-ds4.mat',i);
    
    file_name = fullfile(dir_data,file_data);
    
    data = loadfile(file_name);
    [nsamples,nchannels,~,nfreqs] = size(data.pdc);
    
end