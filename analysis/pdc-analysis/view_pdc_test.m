%% view_pdc_test

test_outdir = fullfile('output','test');
pdc_test_file = fullfile(test_outdir,'pdc-test.mat');
pdc_test_meta_file = fullfile(test_outdir,'pdc-meta-test.mat');
metadata = loadfile(pdc_test_meta_file);

%%
patch_info = ChannelInfo(metadata.patch_labels,...
    'coord', metadata.patch_centroids);
patch_info.populate(metadata.atlas_name);

view_pdc = ViewPDC(metadata.pdcfile,...
    'fs',metadata.fsample,...
    'info',patch_info,...
    'time',metadata.time,...
    'outdir','data',...
    'w',[0 100]/metadata.fsample);

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
flag.plot_pdc_directed_beta_circle = false;
flag.plot_pdc_seed_beta_single = false;
flag.plot_pdc_seed_beta_multiple = true;

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
    view_pdc.plot_directed('makemovie',true,'threshold',0.2,'layout','openhemis','maxdur',40);
end

if flag.plot_pdc_directed_beta_circle
    view_switch(view_pdc,'beta');
    view_pdc.plot_directed('makemovie',true,'threshold',0.2,'layout','circle','maxdur',40);
end

%% pdc seed 15-25Hz
if flag.plot_pdc_seed_beta_single
    view_switch(view_pdc,'beta');
        
    % incoming
    view_pdc.plot_seed(idx,'direction','incoming','threshold',0.05);
    try
        view_pdc.save_plot(save_params{:});
    catch me
    end
end

if flag.plot_pdc_seed_beta_multiple
    view_switch(view_pdc,'beta');
    nchannels = length(view_pdc.info.label);
    % outgoing
    for i=1:nchannels
        view_pdc.plot_seed(i,'direction','outgoing','threshold',0.05,'vertlines',[0 0.5]);
        try
            view_pdc.save_plot(save_params{:},'engine','matlab');
        catch me
        end
        close(gcf);
    end
end

