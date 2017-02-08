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

nchannels_signal = 4;

sparsity = 0.1;
ncouplings = ceil(sparsity*(nchannels_signal^2*norder - nchannels_signal*norder));
% ncouplings = 2;

%% set up alpha process

fresh = true;
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

filters = [];
k=1;

norder_est = 10;
lambda = 0.99;
% gamma = 1;
gamma = 0.1;
filters{k} = MCMTLOCCD_TWL2(nchannels,norder_est,ntrials,'lambda',lambda,'gamma',gamma);
k = k+1;

script_name = [mfilename('fullpath') '.m'];
lf_files = run_lattice_filter(...
    script_name,...
    result.trials_norm,...
    'name','lf-alpha',...
    'filters', filters,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'force',fresh,...
    'plot_pdc', false);

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

%% plot pdc
if flag_plots
    plot_mode = 'tiled';
    save_figs = true;
    params_plot_pdc = {...
        'fs',fsample,...
        'w',freq_range/fsample,...
        };
    plot_pdc_dynamic_from_lf_files(pdc_files,...
        'params',params_plot_pdc,...
        'mode', plot_mode,...
        'outdir', 'data',...
        'save', save_figs);
end

if flag_plots
    plot_pdc_dynamic_from_lf_files(pdc_files,...
        'params',[params_plot_pdc, 'nplots', 5],...
        'mode', 'single-largest',...
        'outdir', 'data',...
        'save', save_figs);
end

%% pdc summary
pdc_get_summary_print(pdc_files{1},...
    params_plot_pdc{:},...
    'nprint',20);

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