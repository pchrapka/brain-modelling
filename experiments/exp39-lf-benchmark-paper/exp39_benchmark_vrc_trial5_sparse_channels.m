%% exp39_benchmark_vrc_trial5_sparse_channels
%   10 channel process with only 4 channels that have couplings
%
%   The goal was to compare this with exp39_benchmark_vrc_trial5 with the 4
%   channel process. Both have the same coupling sparsity level. So I'm
%   curious how the NMSE performance compares
%
%   NOTE a better experiment might be a full 10 channel process with a
%   sparse 10 channel process

%% set options
% nsims = 20;
nchannels = 10;
% nchannels = 4;

norder = 8;
verbosity = 0;

nsims = 1;
ntrials = 5;
lambda = 0.99;

var_params(1).gen_params = {...
    'vrc-sparsechannels-coupling-rnd',nchannels,...
    'version','exp39-sparsechannels4-sparsity0-05'};
var_params(1).noise_sigma = 0.1;
var_params(1).flag_tune = false;

% var_params(2).gen_params = {...
%     'vrc-full-coupling-rnd',nchannels,...
%     'version','exp39-sparsity0-05'};
% var_params(2).noise_sigma = 0.1;
% var_params(2).flag_tune = false;

nsamples = 2000;
var_params(1).gen_config_params = {...
    'order',norder,...
    'nsamples', nsamples,...
    'nsparsechannels', 4,... % 4 out of 10
    'channel_sparsity', 0.4,...
    'coupling_sparsity', 0.05};
% var_params(2).gen_config_params = {...
%     'order',norder,...
%     'nsamples', nsamples,...
%     'channel_sparsity', 0.4,...
%     'coupling_sparsity', 0.05};

for i=1:length(var_params)
    var_gen(i) = VARGenerator(var_params(i).gen_params{:});
    if ~var_gen(i).hasprocess
        var_gen(i).configure(var_params(i).gen_config_params{:});
    end
    % make sure the data already exists
    var_gen(i).generate('sigma',var_params(i).noise_sigma,'ntrials',ntrials*nsims);
end

%% set parameters

outdir = 'vrc-stationary-trial5-nowarmup-sparsechannels';
[file_path,~,~] = fileparts(mfilename('fullpath'));

%% tune parameters
opt = zeros(length(var_params),1);
for i=1:length(var_params)
    if var_params(i).flag_tune
        tune_file = tune_file_from_generator(...
            fullfile(file_path,outdir),...
            'gen_params',var_params(i).gen_params,...
            'gen_config_params',var_params(i).gen_config_params,...
            'ntrials',ntrials);
        
        filter_params = [];
        filter_params.nchannels = nchannels;
        filter_params.ntrials = ntrials;
        filter_params.lambda = lambda;
        filter_params.norder = norder;
        
        %idx_start = floor(nsamples*0.05);
        idx_start = floor(nsamples*0.15);
        idx_end = ceil(nsamples*0.95);
        
        gammas_exp = -14:2:1;
        gammas = [10.^gammas_exp 5 20 30];
        gammas = sort(gammas);
        opt(i) = tune_lattice_filter_gamma(...
            tune_file,...
            fullfile(file_path,outdir),...
            'plot_fit',true,...
            'filter','MCMTLOCCD_TWL4',...
            'filter_params',filter_params,...
            'gamma',gammas,...
            'run_options',{'warmup_noise', false,'warmup_data', false},...
            'criteria_samples',[idx_start idx_end]);
        fprintf('set gamma to %g for process %d\n',opt(i),i);
    end
end
    
for i=1:length(var_params)

    %% set filter parameters
    
    if nchannels == 10
        switch i
            case 1
                var_params(i).gamma = 8.88;
                error('set gamma');
            otherwise
                error('unknown i %d',i);
        end
    else
        error('not set');
    end
    
    %% set up benchmark params
    k=1;
    sim_params = [];
    
    sim_params(k).filter = MCMTQRDLSL1(nchannels,norder,ntrials,lambda);
    sim_params(k).gen_params = var_params(i).gen_params;
    sim_params(k).gen_config_params = var_params(i).gen_config_params;
    sim_params(k).label = sim_params(k).filter.name;
    k = k+1;
    
    sim_params(k).filter = MQRDLSL3(nchannels,norder,lambda);
    sim_params(k).gen_params = var_params(i).gen_params;
    sim_params(k).gen_config_params = var_params(i).gen_config_params;
    sim_params(k).label = sim_params(k).filter.name;
    k = k+1;
    
    % sigma = sqrt(0.1);
    % gamma = sqrt(2*sigma^2*nsamples*log(nchannels));
    
    sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,...
        'lambda',lambda,'gamma',var_params(i).gamma);
    sim_params(k).gen_params = var_params(i).gen_params;
    sim_params(k).gen_config_params = var_params(i).gen_config_params;
    sim_params(k).label = sim_params(k).filter.name;
    k = k+1;
    
    %% run
    [~,data_name,~] = fileparts(var_gen(i).get_file());
    exp_path = fullfile(file_path,[outdir '.m']);
    
    run_lattice_benchmark(...
        'outdir',fullfile(outdir,data_name),...
        'basedir',exp_path,...
        'sim_params', sim_params,...
        'nsims', nsims,...
        'warmup_noise', false,...
        'warmup_data', false,...
        'normalized',true,...
        'force',false,...
        'plot_avg_mse', true,...
        'plot_avg_nmse', true);
end