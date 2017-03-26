function pdc_analysis_view(view_obj,varargin)

p = inputParser();
addRequired(p,'view_obj',@(x) isa(x,'ViewPDC'));
addParameter(p,'envelope',false,@islogical); % also none
addParameter(p,'significance',[],@ischar);
parse(p,view_obj,varargin{:});

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
% flag.plot_pdc_seed_beta = true;
flag.plot_pdc_seed_beta = false;

%% plot rc
if flag.plot_rc
    plot_rc_dynamic_from_lf_files(p.Results.lf_files,...
        'mode', 'summary',...
        'outdir', 'data',...
        'save', true);
end

%% pdc summary 0-100 Hz
if flag.plot_pdc_summary_100
    view_switch(view_obj,'100');
    view_obj.plot_summary();
    view_obj.save_plot(save_params{:})
end

%% pdc single-largest 0-100Hz
% plot indivdiual dynamic pdc plots of largest channel pairs
if flag.plot_pdc_single_100_largest
    view_switch(view_obj,'100');
    nplots = 5;
    view_obj.plot_single_largest('nplots',nplots);
    view_obj.save_plot(save_params{:})
end

%% pdc summary 15-25 Hz sorted magnitude
if flag.plot_pdc_summary_beta_mag
    view_switch(view_obj,'beta');
    out = view_obj.get_summary();
    semilogy(out.mag(out.idx_sorted));
end

%% pdc summary print 15-25 Hz
if flag.print_pdc_summary_beta
    view_switch(view_obj,'beta');
    view_obj.print_summary('nprint',20);
end

%% pdc single 15-25 Hz with mag > 20
if flag.plot_pdc_single_gt20
    threshold = 20;
    view_switch(view_obj,'beta');
    out = view_obj.get_summary('save',true);
    chi_sorted = out.idxi(out.idx_sorted);
    chj_sorted = out.idxj(out.idx_sorted);
    mag_sorted = out.mag(out.idx_sorted);
    mag_thresh_idx = mag_sorted > threshold;
    chi = chi_sorted(mag_thresh_idx);
    chj = chj_sorted(mag_thresh_idx);
    
    view_obj.plot_single_multiple(chj,chi,save_params{:});
end

%% pdc directed movie 15-25Hz
if flag.plot_pdc_directed_beta_hemis
    view_switch(view_obj,'beta');
    view_obj.plot_directed('makemovie',true,'threshold',0.2,'layout','openhemis');
    close(gcf);
end

if flag.plot_pdc_directed_beta_circle
    if p.Results.envelope
        view_switch(view_obj,'10');
    else
        view_switch(view_obj,'beta');
    end
    view_obj.plot_directed('makemovie',true,'threshold',0.2,'layout','circle');
    close(gcf);
end

%% pdc seed 15-25Hz
if flag.plot_pdc_seed_beta
    if p.Results.envelope
        view_switch(view_obj,'10');
    else
        view_switch(view_obj,'beta');
    end
    % outgoing
    for i=1:nchannels
        view_obj.plot_seed(i,'direction','outgoing','threshold',0.2,'vertlines',[0 0.5]);
        try
            view_obj.save_plot(save_params{:},'engine','matlab');
        catch me
        end
        close(gcf);
    end
    
    % incoming
    for i=1:nchannels
        view_obj.plot_seed(i,'direction','incoming','threshold',0.2,'vertlines',[0 0.5]);
        try
            view_obj.save_plot(save_params{:},'engine','matlab');
        catch me
        end
        close(gcf);
    end
end

end