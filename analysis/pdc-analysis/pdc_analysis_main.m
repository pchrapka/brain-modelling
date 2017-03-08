function pdc_analysis_main(varargin)

p = inputParser();
addParameter(p,'metric','euc',@ischar);
addParameter(p,'patch_type','aal',@ischar);
addParameter(p,'ntrials',10,@isnumeric);
addParameter(p,'order',6,@isnumeric);
addParameter(p,'lambda',0.99,@isnumeric);
addParameter(p,'gamma',1,@isnumeric);
addParameter(p,'normalization','allchannels',@ischar); % also none
addParameter(p,'envelope',false,@islogical); % also none
parse(p,varargin{:});


stimulus = 'std';
subject = 3; 
deviant_percent = 10;
% patches_type = 'aal';
% patches_type = 'aal-coarse-13';

[pipeline,outdir] = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,p.Results.patch_type);
lf_file = pipeline.steps{end}.lf.leadfield;
sources_file = pipeline.steps{end}.sourceanalysis;

%% set lattice options
atlas_name = p.Results.patch_type;

lf = loadfile(lf_file);
patch_labels = lf.filter_label(lf.inside);
patch_labels = cellfun(@(x) strrep(x,'_',' '),...
    patch_labels,'UniformOutput',false);
npatch_labels = length(patch_labels);
patch_centroids = lf.patch_centroid(lf.inside,:);
clear lf;

nchannels = npatch_labels;

filters = [];
k=1;

filters{k} = MCMTLOCCD_TWL4(nchannels,p.Results.order,p.Results.ntrials,...
    'lambda',p.Results.lambda,'gamma',p.Results.gamma);
k = k+1;

%% lattice filter

% set up parfor
parfor_setup('cores',12,'force',true);

verbosity = 0;
lf_files = lattice_filter_sources(filters, sources_file,...
    'tracefields',{'Kf','Kb','Rf'},...
    'normalization',p.Results.normalization,...
    'envelope',p.Results.envelope,...
    'verbosity',verbosity,...
    ...'samples',[1:100],...
    'ntrials_max',100,...
    'outdir', outdir);

%% [maybe] remove 300 ms at beg and end

%% compute pdc
downsample_by = 4;
pdc_params = {...
    'metric',p.Results.metric,...
    'downsample',downsample_by,...
    };
pdc_files = rc2pdc_dynamic_from_lf_files(lf_files,'params',pdc_params);

%% plot pdc params

% get fsample
eegphaselocked_file = fullfile(outdir,'fthelpers.ft_phaselocked.mat');
eegdata = loadfile(eegphaselocked_file);
fsample = eegdata.fsample;
time = eegdata.time{1};
time = downsample(time,downsample_by);
clear eegdata;

%% save test file
create_pdc_test = false;
if create_pdc_test
    create_pdc_test_file = false;
    create_pdc_test_meta_file = false;
    
    test_outdir = fullfile('output','test');
    if ~exist(test_outdir,'dir')
        mkdir(test_outdir);
    end
    
    pdc_test_file = fullfile(test_outdir,'pdc-test.mat');
    pdc_test_meta_file = fullfile(test_outdir,'pdc-meta-test.mat');
    
    if create_pdc_test_file
        ntestsamples = 20;
        pdcdata = loadfile(pdc_files{1});
        
        testdata = [];
        testdata.pdc = pdcdata.pdc(1:ntestsamples,:,:,:);
        
        save_parfor(pdc_test_file, testdata);
        clear pdcdata;
        clear testdata
    end
    
    if create_pdc_test_meta_file
        testdata = [];
        testdata.fsample = fsample;
        testdata.atlas_name = atlas_name;
        testdata.patch_labels = patch_labels;
        testdata.patch_centroids = patch_centroids;
        testdata.time = time;
        testdata.pdcfile = pdc_test_file;
        
        save_parfor(pdc_test_meta_file,testdata);
        clear testdata
    end
end

%%

patch_info = ChannelInfo(patch_labels,...
    'coord', patch_centroids);
patch_info.populate(atlas_name);

view_pdc = ViewPDC(pdc_files{1},...
    'fs',fsample,...
    'info',patch_info,...
    'time',time,...
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
flag.plot_pdc_single_gt20 = false;
flag.plot_pdc_directed_beta_hemis = false;
flag.plot_pdc_directed_beta_circle = true;
flag.plot_pdc_seed_beta = true;

%% plot rc
if flag.plot_rc
    plot_rc_dynamic_from_lf_files(lf_files,...
        'mode', 'summary',...
        'outdir', 'data',...
        'save', true);
end

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

%% pdc directed movie 15-25Hz
if flag.plot_pdc_directed_beta_hemis
    view_switch(view_pdc,'beta');
    view_pdc.plot_directed('makemovie',true,'threshold',0.2,'layout','openhemis');
    close(gcf);
end

if flag.plot_pdc_directed_beta_circle
    if p.Results.envelope
        view_switch(view_pdc,'10');
    else
        view_switch(view_pdc,'beta');
    end
    view_pdc.plot_directed('makemovie',true,'threshold',0.2,'layout','circle');
    close(gcf);
end

%% pdc seed 15-25Hz
if flag.plot_pdc_seed_beta
    if p.Results.envelope
        view_switch(view_pdc,'10');
    else
        view_switch(view_pdc,'beta');
    end
    % outgoing
    for i=1:nchannels
        view_pdc.plot_seed(i,'direction','outgoing','threshold',0.2,'vertlines',[0 0.5]);
        try
            view_pdc.save_plot(save_params{:},'engine','matlab');
        catch me
        end
        close(gcf);
    end
    
    % incoming
    for i=1:nchannels
        view_pdc.plot_seed(i,'direction','incoming','threshold',0.2,'vertlines',[0 0.5]);
        try
            view_pdc.save_plot(save_params{:},'engine','matlab');
        catch me
        end
        close(gcf);
    end
end

end