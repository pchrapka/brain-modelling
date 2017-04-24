%% exp38_warmup_concat

%% set options
% nsims = 20;
nsims = 1;
nsims_benchmark = nsims;
ntrials = 5;

nchannels = 4;

order_est = 10;
lambda = 0.99;

verbosity = 0;

% gen_params = 'vrc-coupling0-fixed';
% nsamples = 2000;
% gen_config_params = {'nsamples', nsamples};

gen_params = {'vrc-cp-ch2-coupling1-fixed',nchannels};
gen_config_params = {};

var_gen = VARGenerator(gen_params{:});
if ~var_gen.hasprocess
    var_gen.configure(gen_config_params{:});
end
data_var = var_gen.generate('ntrials',nsims*ntrials);

%% create data sets

data_orig = data_var.signal_norm(:,:,nsims*ntrials);
data_configs = {{'data'}

% data

% noise data

% noise data data

% noise flipdata data


%% set up filter

sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

filters = {};
filters{1} = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);

%% run filter
[~,exp_name,~] = fileparts(data_file);
outdir = 'output';

lf_files = run_lattice_filter(...
    data_file,...
    'basedir',outdir,...
    'outdir',exp_name,...
    'filters', filters,...
    'warmup_noise', false,...
    'warmup_data', false,...
    'force',false,...
    'verbosity',0,...
    'tracefields',{'Kf','Kb','ferror','berrord'},...
    'plot_pdc', false);