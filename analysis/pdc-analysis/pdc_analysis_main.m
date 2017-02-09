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
save_figs = true;
plot_mode = 'summary';

% plot_rc_dynamic_from_lf_files(lf_files,...
%     'mode', plot_mode,...
%     'outdir', 'data',...
%     'save', save_figs);

%% compute pdc
pdc_params = {...
    'metric','euc',...
    'downsample',4,...
    };
pdc_files = rc2pdc_dynamic_from_lf_files(lf_files,'params',pdc_params);

%% plot pdc

% get fsample
eegphaselocked_file = fullfile(outdir,'fthelpers.ft_phaselocked.mat');
eegdata = loadfile(eegphaselocked_file);
fsample = eegdata.fsample;
clear eegdata;

params_plot_pdc = {...
    'fs',fsample,...
    'w',[0 100]/fsample,...
    };

plot_pdc_dynamic_from_lf_files(pdc_files,...
    'mode', plot_mode,...
    'outdir', 'data',...
    'params',params_plot_pdc,...
    'save', save_figs);

%% plot indivdiual dynamic pdc plots of largest channel pairs
nplots = 5;
plot_pdc_dynamic_from_lf_files(pdc_files,...
    'mode', 'single-largest',...
    'params', [params_plot_pdc, 'nplots', nplots, 'ChannelLabels', {patch_labels}],...
    'outdir', 'data',...
    'save', save_figs);

%%
params_summary_beta = {'fs',fsample,'w',[15 25]/fsample};

out = pdc_get_summary(pdc_files{1},params_summary_beta{:});
semilogy(out.mag(out.idx_sorted));

%%
pdc_get_summary_print(pdc_files{1},...
    params_summary_beta{:},...
    'nprint',20,...
    'labels',patch_labels);
