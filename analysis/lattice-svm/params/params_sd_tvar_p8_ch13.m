function params = params_sd_tvar_p8_ch13(varargin)
% params for time varying VAR, order = 8, channels = 13

p = inputParser();
addParameter(p,'mode','all',@(x) any(validatestring(x,{'all','short'})));
p.parse(varargin{:});

%% generate data

norder = 8;
nsets_max = 120;
ntrials_max = 8;
ntrials = nsets_max*ntrials_max;
nchannels = 13;
ntime = 358;

params = [];
params.restart = false;

conds = [];
conds(1).label = 'std';
conds(1).opt_func = 'params_al_std';
conds(2).label = 'odd';
conds(2).opt_func = 'params_al_odd';
ncond = length(conds);

outdir = fullfile(get_project_dir(),'experiments','output-common','simulated');
if ~exist(outdir,'dir')
    mkdir(outdir);
end
[~,func_name,~] = fileparts(mfilename('fullpath'));

% set different changepoints for the conditions
changepoints = {};
changepoints{1} = [20 100] + (ntime - 256);
changepoints{2} = [50 120] + (ntime - 256);

params.conds = conds;
for i=1:ncond
    % set up params
    params.conds(i).path = fullfile(outdir,...
        sprintf('%s-%s',strrep(func_name,'_','-'),conds(i).label));
    outpath = params.conds(i).path;
    
    var_gen = VARGenerator('vrc-cp-ch2-coupling2-rnd', nchannels,'version',i);
    params.var_gen(i) = var_gen;
    
    % determine new and old trials
    data_new_trials = false(ntrials,1);
    if exist(var_gen.get_file(),'file')
        % get number of trials already existing
        data_var = loadfile(var_gen.get_file());
        data_ntrials = size(data_var.signal,3);
        if ntrials > data_ntrials
            data_new_trials(data_ntrials+1:ntrials,1) = true;
        end
    else
        data_new_trials(1:ntrials,1) = true;
    end
    
    % generate data
    var_gen_params = {'time',ntime,'order',norder,'changepoints',changepoints{i}};
    params.var_gen_params{i} = var_gen_params;
    if ~var_gen.hasprocess
        var_gen.configure(var_gen_params{:});
    end
    data_var = var_gen.generate('ntrials',ntrials);
    
    for j=1:ntrials
        outfile = fullfile(outpath,sprintf('trial%d.mat',j));
        params.conds(i).trials(j).file = outfile;
        params.conds(i).trials(j).restart = data_new_trials(j);
        
        if data_new_trials(j) || ~exist(outfile,'file')
            % create trial data
            data = [];
            % create source analysis data
            data.label = conds(i).label;
            data.inside = ones(nchannels,1);
            data.avg.mom = cell(nchannels,1);
            data.time = linspace(-0.5,1,ntime);
            for k=1:nchannels
                data.avg.mom{k} = data_var.signal(k,:,j); %[1 time]
            end
            
            % save data
            save_parfor(outfile,data);
        else
            fprintf('trial %d source data exists: %s\n',j,outfile);
        end
    end
end

if isequal(p.Results.mode,'short')
    return;
end

k=1;

%% params_lf_MQRDLSL2_p10_l099

params.analysis(k).lf = 'params_lf_MQRDLSL2_p10_l099';
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

params.analysis(k).lf = 'params_lf_MQRDLSL2_p10_l099';
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

params.analysis(k).lf = 'params_lf_MQRDLSL2_p10_l099';
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

params.analysis(k).lf = 'params_lf_MQRDLSL2_p10_l099';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MLOCCDTWL_p10_l099_g16

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099_g16';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099_g16';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099_g16';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099_g16';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MLOCCDTWL_p10_l098_g16

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098_g16';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098_g16';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098_g16';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098_g16';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTQRDLSL1_mt2_p10_l099

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099';
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
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099';
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

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099';
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
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt3_p10_l099

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt3_p10_l099';
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
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt3_p10_l099';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt5_p10_l099

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l099';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l099';
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


params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l099';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l099';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTQRDLSL1_mt8_p10_l099

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt8_p10_l099';
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
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt8_p10_l099';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt2_p10_l098

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098';
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
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098';
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

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098';
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
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt5_p10_l098

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l098';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l098';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l098';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l098';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTQRDLSL1_mt2_p10_l09

% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l09';
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
% params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l09';
% params.analysis(k).fm = 'params_fm_lattice_nothresh';
% params.analysis(k).pd = '';
% params.analysis(k).fd = '';
% params.analysis(k).fv = {};
% params.analysis(k).tt = {};
% k = k+1;

%% params_lf_MCMTQRDLSL1_mt5_p10_l09
params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l09';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p10_l09';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTLOCCDTWL2_mt5_p10_l099_g28

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l099_g28';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l099_g28';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l099_g28';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l099_g28';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTLOCCDTWL2_mt5_p10_l098_g28

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l098_g28';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l098_g28';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l098_g28';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l098_g28';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

end
