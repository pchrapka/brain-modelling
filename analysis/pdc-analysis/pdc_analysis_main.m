%% pdc_analysis_main

stimulus = 'std';
subject = 3; 
deviant_percent = 10;
patches_type = 'aal';
% patches_type = 'aal-coarse-13';

%% output dir

[data_file,data_name,~] = get_data_andrew(subject,deviant_percent);

% dataset = data_file;
data_name2 = sprintf('%s-%s',stimulus,data_name);
analysis_dir = fullfile(get_project_dir(),'analysis','pdc-analysis');
outdir = fullfile(analysis_dir,'output',data_name2);

%% preprocess data for beamforming
eeg_preprocessing_andrew(subject,deviant_percent,stimulus,...
    'patches',patches_type,...
    'outdir',outdir);

%% beamform sources
pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(...
    subject,deviant_percent,stimulus,'patches',patches_type)); 
pipeline.process();

%% compute induced sources
eeg_file = fullfile(outdir,'ft_rejectartifact.mat');
lf_file = pipeline.steps{end}.lf.leadfield;
sources_file = pipeline.steps{end}.sourceanalysis;

eeg_induced(sources_file, eeg_file, lf_file, 'outdir',outdir);

%% set lattice options
lf = loadfile(lf_file);
patch_labels = lf.filter_label(lf.inside);
patch_labels = cellfun(@(x) strrep(x,'_',' '),...
    patch_labels,'UniformOutput',false);
npatch_labels = length(patch_labels);
clear lf;

nchannels = npatch_labels;
ntrials = 20;
order_est = 10;
lambda = 0.99;
gamma = 1;

filters = [];
k=1;

% filters{k} = MCMTLOCCD_TWL2(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
% k = k+1;

filters{k} = MCMTLOCCD_TWL2(nchannels,order_est,2*ntrials,'lambda',lambda,'gamma',gamma);
k = k+1;

%% lattice filter

verbosity = 2;
lf_files = lattice_filter_sources(filters, sources_file,...
    'verbosity',verbosity,...
    ...'samples',[1:100],...
    'ntrials_max',100,...
    'outdir', outdir);

%% [maybe] remove 300 ms at beg and end

%% plot rc
if flag.plot_rc
    plot_rc_dynamic_from_lf_files(lf_files,...
        'mode', 'summary',...
        'outdir', 'data',...
        'save', true);
end

%% compute pdc
pdc_params = {...
    'metric','euc',...
    'downsample',4,...
    };
pdc_files = rc2pdc_dynamic_from_lf_files(lf_files,'params',pdc_params);

%% plot pdc params

% get fsample
eegphaselocked_file = fullfile(outdir,'fthelpers.ft_phaselocked.mat');
eegdata = loadfile(eegphaselocked_file);
fsample = eegdata.fsample;
clear eegdata;

%%
view_pdc = ViewPDC(pdc_files{1},...
    'fs',fsample,...
    'labels',patch_labels,...
    'outdir','data',...
    'w',[0 100]/fsample);

save_params = {...
    'save', true,...
    };

%% plot flags
flag = [];
flag.plot_rc = false;
flag.plot_pdc_summary_100 = false;
flag.plot_pdc_single_100_largest = false;
flag.plot_pdc_summary_beta_mag = false;
flag.print_pdc_summary_beta = false;
flag.plot_pdc_single_gt20 = true;

%% pdc summary 0-100 Hz
if flag.plot_pdc_summary_100
    view_switch(view_pdc,'100');
    view_pdc.plot_summary();
    view_pdc.save_plot(save_params{:})
end

%% pdc single-largest 0-100Hz
% plot indivdiual dynamic pdc plots of largest channel pairs
if flag.plot_pdc_single_100_largest
    view_switch(view_pdc,'100');
    nplots = 5;
    view_pdc.plot_single_largest('nplots',nplots);
    view_pdc.save_plot(save_params{:})
end

%% pdc summary 15-25 Hz sorted magnitude
if flag.plot_pdc_summary_beta_mag
    view_switch(view_pdc,'beta');
    out = view_pdc.get_summary();
    semilogy(out.mag(out.idx_sorted));
end

%% pdc summary print 15-25 Hz
if flag.print_pdc_summary_beta
    view_switch(view_pdc,'beta');
    view_pdc.print_summary('nprint',20);
end

%% pdc single 15-25 Hz with mag > 20
if flag.plot_pdc_single_gt20
    threshold = 20;
    view_switch(view_pdc,'beta');
    out = view_pdc.get_summary('save',true);
    chi_sorted = out.idxi(out.idx_sorted);
    chj_sorted = out.idxj(out.idx_sorted);
    mag_sorted = out.mag(out.idx_sorted);
    mag_thresh_idx = mag_sorted > threshold;
    chi = chi_sorted(mag_thresh_idx);
    chj = chj_sorted(mag_thresh_idx);
    
    view_pdc.plot_single_multiple(chj,chi,save_params{:});
end

