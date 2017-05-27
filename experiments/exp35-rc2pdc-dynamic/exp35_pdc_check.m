%% exp35_pdc_check

% check optimized pdc vs original pdc for all metrics

%% options

nchannels = 4;
norder = 10;
order_est = norder;

nsamples = 500;
ntrials = 5;

%% set up vrc
vrc_type = 'vrc-cp-ch2-coupling2-rnd';
vrc_type_params = {}; % use default
vrc_gen = VARGenerator(vrc_type, nchannels, 'version', 1);
if ~vrc_gen.hasprocess
    vrc_gen.configure(vrc_type_params{:});
end
data_vrc = vrc_gen.generate('ntrials',2*ntrials);

vrc_data_file = loadfile(vrc_gen.get_file());

% Kf = vrc_data_file.Kf(1,:,:,:);
% Kb = vrc_data_file.Kb(1,:,:,:);

%% lattice filter

fresh = false;
lambda = 0.99;
gamma = 0.1;

filters = {};
k = 1;
filters{k} = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
k = k+1;

script_name = [mfilename('fullpath') '.m'];
lf_files = run_lattice_filter(...
    vrc_data_file.signal_norm,...
    'outdir','output',...
    'basedir',script_name,...
    'filters', filters,...
    'warmup',{'noise','data'},...
    'tracefields',{'Kf','Kb','Rf'},...
    'force',fresh,...
    'plot_pdc', false);

%% load lf results

data = loadfile(lf_files{1});
Kf = squeeze(data.estimate.Kf(100,:,:,:));
Kb = squeeze(data.estimate.Kb(100,:,:,:));
Pf_orig = squeeze(data.estimate.Rf(100,data.filter.order,:,:));
Pf = (1-lambda)/(1-lambda^100) * Pf_orig;

%% loop over metrics
metrics = {'euc','diag','info'};
nmetrics = length(metrics);
for i=1:nmetrics
    metric = metrics{i};
    
    %% rc2pdc original
    
    A2 = rcarrayformat(rc2ar(Kf,Kb),'format',3,'transpose',false);
    result_orig = pdc_orig(A2,Pf,'metric',metric);
    
    %% rc2pdc optimized
    
    result_opt = rc2pdc(Kf, Kb, Pf,...
        'metric',metric,...
        'parfor',true);
    
    %% check results
    if isequalntol(result_opt.pdc,result_orig.pdc,'AbsTol',1e-3)
        fprintf('%s matches\n',metric);
    else
        fprintf('%s does not match\n',metric);
    end
end