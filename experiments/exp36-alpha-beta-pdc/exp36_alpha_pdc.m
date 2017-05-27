%% exp36_alpha_pdc
% test frequency band pdc

flag_plots = true;
flag_check = true;

%%

nchannels = 5;
norder = 6;

nsamples = 5000;
ntrials = 5;
ntrials_gen = ntrials*2;
nsamples_filter = nsamples/ntrials_gen;
fsample = 100;
% fsample = 4*10;
freq_range = [8 10];
time = ((0:nsamples_filter-1) - floor(nsamples_filter/4))/fsample;

nchannels_signal = 4;

sparsity = 0.1;
ncouplings = ceil(sparsity*(nchannels_signal^2*norder - nchannels_signal*norder));
% ncouplings = 2;

%% set up alpha process

fresh = false;
alpha_file = fullfile(pwd,'output','alpha.mat');

if fresh || ~exist(alpha_file,'file')
    % fieldtrip overloads matlab's butter function
    cd ../..
    restoredefaultpath
    startup_project
    cd experiments/exp36-alpha-beta-pdc
    
    result = generate_freq_process(...
        'nchannels',nchannels,...
        'ntrials',ntrials_gen,...
        'nsamples',nsamples,...
        'norder',norder,...
        'ncoupling',ncouplings,...
        'nchannels_signal',nchannels_signal,...
        'freq',freq_range,...
        'fs',fsample,...
        'normalization','all',...
        'nsamples_warmup',nsamples);
    
    save_parfor(alpha_file,result);
    
    cd ../..
    startup
    cd experiments/exp36-alpha-beta-pdc
    
else
    result = loadfile(alpha_file);
end

%%
% plot_trials(result.trials);
% plot_trials(result.trials_norm);

%%
fprintf('coupling coefficients\n');
for i=1:norder
    fprintf('order %d\n',i);
    disp(result.A(:,:,i));
end

fprintf('summed together\n');
disp(sum(result.A,3));

%% lattice filter


norder_est = 10;
lambda = 0.99;
gammas = [0.1 1];
data_labels = {'gamma 0.1','gamma 1'};

filters = {};
for k=1:length(gammas)
    gamma = gammas(k);
    filters{k} = MCMTLOCCD_TWL4(nchannels,norder_est,ntrials,'lambda',lambda,'gamma',gamma);
end

script_name = [mfilename('fullpath') '.m'];
lf_files = run_lattice_filter(...
    result.trials_norm,...
    'outdir',fullfile('output','lf-alpha'),...
    'basedir',script_name,...
    'filters', filters,...
    'warmup',{'noise','data'},...
    'tracefields',{'Kf','Kb','ferror','berrord'},...
    'force',fresh,...
    'plot_pdc', false);

%% set up view lattice
view_lf = ViewLatticeFilter(lf_files{1});
crit_time = {'ewaic','ewsc','normerrortime'};
crit_single = {'aic','sc','norm'};
view_lf.compute([crit_time crit_single]);

%% plot order vs estimation error
view_lf.plot_criteria_vs_order_vs_time('criteria','ewaic','orders',1:norder_est);
view_lf.plot_criteria_vs_order_vs_time('criteria','ewsc','orders',1:norder_est);
view_lf.plot_criteria_vs_order_vs_time('criteria','normerrortime','orders',1:norder_est);

view_lf.plot_criteria_vs_order('criteria','aic','orders',1:norder_est);
view_lf.plot_criteria_vs_order('criteria','sc','orders',1:norder_est);
view_lf.plot_criteria_vs_order('criteria','norm','orders',1:norder_est);

%% set up view lattice for both files
view_lf = ViewLatticeFilter(lf_files,'labels',data_labels);
view_lf.compute({'ewaic','aic'});
view_lf.plot_criteria_vs_order_vs_time('criteria','ewaic','orders',1:2,'file_list',1:length(lf_files));
view_lf.plot_criteria_vs_order('criteria','aic','orders',1:2,'file_list',1:length(lf_files));

%%
if flag_plots
    plot_mode = 'tiled';
    save_figs = true;
    plot_rc_dynamic_from_lf_files(lf_files,...
        'mode', plot_mode,...
        'outdir', 'data',...
        'save', save_figs);
end

%% compute pdc
pdc_params = {...
    'metric','euc',...
    'downsample','none',...
    };
pdc_files = rc2pdc_dynamic_from_lf_files(lf_files,'params',pdc_params);

%% set up view pdc
view_pdc = ViewPDC(...
    'fs',fsample,...
    'labels',{},...
    'time',time,...
    'outdir','data',...
    'w',freq_range/fsample);
view_pdc.file_pdc = pdc_files{1};

save_params = {...
    'save', true,...
    };


%% plot pdc

if flag_plots
    view_pdc.plot_tiled();
    view_pdc.save_plot(save_params{:});
end

if flag_plots
    view_pdc.plot_single_largest('nplots', 5);
    view_pdc.save_plot(save_params{:});
end

%view_pdc.plot_adjacency();
%view_pdc.plot_directed('makemovie',true);
view_pdc.plot_seed(2,'direction','outgoing');

%% pdc summary
view_pdc.print_summary('nprint',20);

%% compare sparse LF coefficients with mcarns2
if flag_check
    Kf = zeros(2,nchannels,nchannels,norder_est);
    Kb = Kf;
    [npf,na,npb,nb,nef,neb, ~,Kf(2,:,:,:),Kb(2,:,:,:)] = ...
        mcarns2(result.data_norm,norder_est);
    
    data = [];
    data.estimate.Kf = Kf;
    data.estimate.Kb = Kb;
    mcarns_file = fullfile(pwd,'lf-ns','mcarns2.mat');
    save_parfor(mcarns_file, data);
    plot_rc_dynamic_from_lf_files(mcarns_file,'mode','tiled','outdir','data','save',true);
end

%% compare AR coefficients with mcarns2
if flag_check
    data_lf = loadfile(lf_files{1});
    idx = ceil(nsamples_filter/2);
    Kftemp = squeeze(data_lf.estimate.Kf(idx,:,:,:));
    Kbtemp = squeeze(data_lf.estimate.Kb(idx,:,:,:));
    A2 = rcarrayformat(rc2ar(Kftemp,Kbtemp),'format',3);
    
    data_temp = [];
    data_temp.Kf(1,:,:,:) = zeros(size(A2));
    data_temp.Kf(2,:,:,:) = A2;
    figure;
    %plot_rc(data_temp,'mode','image-order');
    plot_rc_dynamic(data_temp.Kf);
    set(gcf,'Name','AR: Lattice Filter');
    
    data_temp = [];
    data_temp.Kf(1,:,:,:) = zeros(size(na));
    data_temp.Kf(2,:,:,:) = na;
    figure;
    %plot_rc(data_temp,'mode','image-order');
    plot_rc_dynamic(data_temp.Kf);
    set(gcf,'Name','AR: mcarns2');
end

%% pdc using asymptotics

alg = 1; % nuttal strand
alpha = 0.05;
criterion = 1;
result2 = pdc_alg(result.data_norm,128,'euc',alg,criterion,norder_est,alpha);

if flag_plots
    flg_print = [1 1 1 0 0 0 0];
    fs = 1;
    w_max = fs/2;
    ch_labels = [];
    flg_color = 0;
    flg_sigcolor = 1;
    
    h=figure;
    % set(h,'NumberTitle','off','MenuBar','none', 'Name', name )
    xplot(result2,flg_print,fs,w_max,ch_labels,flg_color,flg_sigcolor);
end