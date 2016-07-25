function params = params_sd_tvar_p8_ch13()
% params for time varying VAR, order = 8, channels = 13

[srcdir,func_name,~] = fileparts(mfilename('fullpath'));

%% generate data

norder = 8;
ntrials = 270;
nchannels = 13;
ntime = 358;

params = [];

conds = [];
conds(1).label = 'std';
conds(1).opt_func = 'params_al_std';
conds(2).label = 'odd';
conds(2).opt_func = 'params_al_odd';
ncond = length(conds);

outdir = fullfile(srcdir,...
    '..','experiments','output-common','simulated');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

% ncoefs = norder;
% sparsity = 0.1;
% ncoefs_sparse = ceil(ncoefs*sparsity);
ncoefs_sparse = 2;

ncouplings = 2;

% Rationale: for each condition use the same VAR models for the constant
% and pulse processes, change the coupling and changepoints to account for
% the change in condition

% set up 2 1-channel VAR model with random coefficients
var1 = VAR(1, norder);
var1.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse,...
    'stable',true,'verbose',1);

var2 = VAR(1, norder);
var2.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse,...
    'stable',true,'verbose',1);

source_channels = randsample(1:nchannels,2);

% set const to var 1
var_const = zeros(nchannels, nchannels, norder);
var_const(source_channels(1),source_channels(1),:) = var1.A;

% set pulse to var 2
var_pulse = zeros(nchannels, nchannels, norder);
var_pulse(source_channels(2),source_channels(2),:) = var2.A;

% set different changepoints for the conditions
changepoints = {};
changepoints{1} = [20 100] + (ntime - 256);
changepoints{2} = [50 120] + (ntime - 256);

for i=1:ncond
    % set up params
    params.conds(i).file = fullfile(outdir,...
        sprintf('%s-%s.mat',strrep(func_name,'_','-'),conds(i).label));
    params.conds(i).opt_func = conds(i).opt_func;
    
    % check if the data file exists
    if ~exist(params.conds(i).file,'file')
        stable = false;
        while ~stable

            % modify coupling for each condition
            var_coupling = zeros(nchannels, nchannels, norder);
            coupling_count = 0;
            while coupling_count < ncouplings
                
                coupled_channels = randsample(source_channels,2);
                coupled_order = randsample(1:norder,1);
                
                % check if we've already chosen this one
                if var_coupling(coupled_channels(1),coupled_channels(2),coupled_order) == 0
                    % generate a new coefficient
                    var_coupling(coupled_channels(1),coupled_channels(2),coupled_order) = unifrnd(-1, 1);
                    % increment counter
                    coupling_count = coupling_count + 1;
                end
            end
            
            % add const and coupling to pulse
            var_pulse = var_const + var_coupling + var_pulse;
            
            var_constpulse = VARConstAndPulse(nchannels, norder, changepoints{i});
            
            var_constpulse.coefs_set(var_const, 'const');
            var_constpulse.coefs_set(var_pulse, 'pulse');
            
            % check stability
            verbosity = true;
            stable = var_constpulse.coefs_stable(verbosity);
        end
            
        % generate data
        data = [];
        data(ntrials).inside = [];
        for j=1:ntrials
            % simulate process
            [signal,~,~] = var_constpulse.simulate(ntime);
            
            data(j).label = conds(i).label;
            data(j).inside = ones(nchannels,1);
            data(j).avg.mom = cell(nchannels,1);
            data(j).time = linspace(-0.5,1,ntime);
            for k=1:nchannels
                data(j).avg.mom{k} = signal(k,ntime+1:end); %[1 time]
            end
        end
        
        % save data
        save(params.conds(i).file,'data');
    else
        fprintf('data exists: %s\n',params.conds(i).file);
    end

end

k=1;

%% params_lf_MQRDLSL2_p10_l099_n400

params.analysis(k).lf = 'params_lf_MQRDLSL2_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MQRDLSL2_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5clamp';
params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MQRDLSL2_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh_scalefw';
params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MQRDLSL2_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MLOCCDTWL_p10_l099_n400

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5clamp';
params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh_scalefw';
params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MLOCCDTWL_p10_l098_n400

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5clamp';
params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh_scalefw';
params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTQRDLSL1_mt2_p10_l099_n400

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400';
% params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
% params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
% params.analysis(k).fd = 'params_fd_20000';
% params.analysis(k).fv = {...
%     'params_fv_rbf_20',...
%     'params_fv_rbf_40',...
%     ...'params_fv_rbf_60',...
%     ...'params_fv_rbf_100',...
%     };
% params.analysis(k).tt = {...
%     'params_tt_rbf_10',...
%     'params_tt_rbf_20',...
%     ...'params_tt_rbf_30',...
%     ...'params_tt_rbf_50',...
%     };
% k = k+1;
% 
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400';
% params.analysis(k).fm = 'params_fm_lattice_thresh1dot5clamp';
% params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
% params.analysis(k).fd = 'params_fd_20000';
% params.analysis(k).fv = {...
%     'params_fv_rbf_20',...
%     'params_fv_rbf_40',...
%     ...'params_fv_rbf_60',...
%     ...'params_fv_rbf_100',...
%     };
% params.analysis(k).tt = {...
%     'params_tt_rbf_10',...
%     'params_tt_rbf_20',...
%     ...'params_tt_rbf_30',...
%     ...'params_tt_rbf_50',...
%     };
% k = k+1;

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400';
% params.analysis(k).fm = 'params_fm_lattice_nothresh_scalefw';
% params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
% params.analysis(k).fd = 'params_fd_20000';
% params.analysis(k).fv = {...
%     'params_fv_rbf_20',...
%     'params_fv_rbf_40',...
%     ...'params_fv_rbf_60',...
%     ...'params_fv_rbf_100',...
%     };
% params.analysis(k).tt = {...
%     'params_tt_rbf_10',...
%     'params_tt_rbf_20',...
%     ...'params_tt_rbf_30',...
%     ...'params_tt_rbf_50',...
%     };
% k = k+1;
% 
% 
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt3_p10_l099_n400

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400';
% params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
% params.analysis(k).pd = 'params_pd_std_odd_tr70_te20';
% params.analysis(k).fd = 'params_fd_20000';
% params.analysis(k).fv = {...
%     'params_fv_rbf_20',...
%     'params_fv_rbf_40',...
%     ...'params_fv_rbf_60',...
%     ...'params_fv_rbf_100',...
%     };
% params.analysis(k).tt = {...
%     'params_tt_rbf_10',...
%     'params_tt_rbf_20',...
%     ...'params_tt_rbf_30',...
%     ...'params_tt_rbf_50',...
%     };
% k = k+1;
% 
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt5_p10_l099_n400

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
params.analysis(k).pd = 'params_pd_std_odd_tr30_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5clamp';
params.analysis(k).pd = 'params_pd_std_odd_tr30_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;


params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh_scalefw';
params.analysis(k).pd = 'params_pd_std_odd_tr30_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTQRDLSL1_mt8_p10_l099_n400

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt8_p10_l099_n400';
% params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
% params.analysis(k).pd = 'params_pd_std_odd_tr20_te10';
% params.analysis(k).fd = 'params_fd_20000';
% params.analysis(k).fv = {...
%     'params_fv_rbf_20',...
%     'params_fv_rbf_40',...
%     ...'params_fv_rbf_60',...
%     ...'params_fv_rbf_100',...
%     };
% params.analysis(k).tt = {...
%     'params_tt_rbf_10',...
%     'params_tt_rbf_20',...
%     ...'params_tt_rbf_30',...
%     ...'params_tt_rbf_50',...
%     };
% k = k+1;
% 
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt8_p10_l099_n400';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt2_p10_l098_n400

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400';
% params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
% params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
% params.analysis(k).fd = 'params_fd_20000';
% params.analysis(k).fv = {...
%     'params_fv_rbf_20',...
%     'params_fv_rbf_40',...
%     ...'params_fv_rbf_60',...
%     ...'params_fv_rbf_100',...
%     };
% params.analysis(k).tt = {...
%     'params_tt_rbf_10',...
%     'params_tt_rbf_20',...
%     ...'params_tt_rbf_30',...
%     ...'params_tt_rbf_50',...
%     };
% k = k+1;
% 
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400';
% params.analysis(k).fm = 'params_fm_lattice_thresh1dot5clamp';
% params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
% params.analysis(k).fd = 'params_fd_20000';
% params.analysis(k).fv = {...
%     'params_fv_rbf_20',...
%     'params_fv_rbf_40',...
%     ...'params_fv_rbf_60',...
%     ...'params_fv_rbf_100',...
%     };
% params.analysis(k).tt = {...
%     'params_tt_rbf_10',...
%     'params_tt_rbf_20',...
%     ...'params_tt_rbf_30',...
%     ...'params_tt_rbf_50',...
%     };
% k = k+1;

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400';
% params.analysis(k).fm = 'params_fm_lattice_nothresh_scalefw';
% params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
% params.analysis(k).fd = 'params_fd_20000';
% params.analysis(k).fv = {...
%     'params_fv_rbf_20',...
%     'params_fv_rbf_40',...
%     ...'params_fv_rbf_60',...
%     ...'params_fv_rbf_100',...
%     };
% params.analysis(k).tt = {...
%     'params_tt_rbf_10',...
%     'params_tt_rbf_20',...
%     ...'params_tt_rbf_30',...
%     ...'params_tt_rbf_50',...
%     };
% k = k+1;
% 
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt5_p10_l098_n400

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l098_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
params.analysis(k).pd = 'params_pd_std_odd_tr30_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l098_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5clamp';
params.analysis(k).pd = 'params_pd_std_odd_tr30_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l098_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh_scalefw';
params.analysis(k).pd = 'params_pd_std_odd_tr30_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l098_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTQRDLSL1_mt2_p10_l09_n400

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l09_n400';
% params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
% params.analysis(k).pd = 'params_pd_std_odd_tr100_te20';
% params.analysis(k).fd = 'params_fd_20000';
% params.analysis(k).fv = {...
%     'params_fv_rbf_20',...
%     'params_fv_rbf_40',...
%     ...'params_fv_rbf_60',...
%     ...'params_fv_rbf_100',...
%     };
% params.analysis(k).tt = {...
%     'params_tt_rbf_10',...
%     'params_tt_rbf_20',...
%     ...'params_tt_rbf_30',...
%     ...'params_tt_rbf_50',...
%     };
% k = k+1;
% 
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l09_n400';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt5_p10_l09_n400
params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l09_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
params.analysis(k).pd = 'params_pd_std_odd_tr30_te20';
params.analysis(k).fd = 'params_fd_20000';
params.analysis(k).fv = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    ...'params_fv_rbf_60',...
    ...'params_fv_rbf_100',...
    };
params.analysis(k).tt = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    ...'params_tt_rbf_30',...
    ...'params_tt_rbf_50',...
    };
k = k+1;

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l09_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

end