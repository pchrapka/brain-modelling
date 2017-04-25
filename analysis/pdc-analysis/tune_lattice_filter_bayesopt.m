%% tune_lattice_filter_bayesopt

% TODO load data and set up data file

nchannels = 8;
norder = 10;
ntrials = 20;
nsamples = ; % get from data

idx_start = floor(nsamples*0.05);
idx_end = ceil(nsamples*0.95);

func = @(x) tune_lattice_filter(...
    data_file,...
    outdir,...
    'filter','MCMTLOCCD_TWL4',...
    'filter_params',{nchannels,norder,ntrials,'lambda',x(2),'gamma',x(1)},...
    'criteria','normtime',...
    'criteria_samples',[idx_start idx_end]);

ub = [10 1]; %[gamma lambda]
lb = zeros(n,1);

[x_opt,y] = bayesoptcont(func, n, params, lb, ub);