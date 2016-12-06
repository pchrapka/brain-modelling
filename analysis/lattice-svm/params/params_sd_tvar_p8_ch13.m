function params = params_sd_tvar_p8_ch13()
% params for time varying VAR, order = 8, channels = 13

%% generate data

norder = 8;
nsets_max = 120;
ntrials_max = 8;
ntrials = max(nsets_max*ntrials_max,2000);
nchannels = 13;
ntime = 358;

params = [];
params.force = false;

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

for i=1:ncond
    % set up params
    params.conds(i).file = fullfile(outdir,...
        sprintf('%s-%s.mat',strrep(func_name,'_','-'),conds(i).label));
    params.conds(i).opt_func = conds(i).opt_func;
    outfile = params.conds(i).file;
    
    var_gen = VARGenerator('vrc-cp-ch2-coupling2-rnd', ntrials, nchannels,'version',i);
    data_var = var_gen.generate('time',ntime,'order',norder,'changepoints',changepoints{i});
    % get the data time stamp
    data_time = get_timestamp(var_gen.get_file());
    
    fresh = false;
    if exist(outfile,'file')
        % check freshness of data and source analysis
        source_time = get_timestamp(outfile);
        if data_time > source_time
            fresh = true;
        end
    end
    
    % use data
    if fresh || ~exist(outfile,'file')
        % generate data
        data = [];
        data(ntrials).inside = [];
        for j=1:ntrials
            % create source analysis data
            data(j).label = conds(i).label;
            data(j).inside = ones(nchannels,1);
            data(j).avg.mom = cell(nchannels,1);
            data(j).time = linspace(-0.5,1,ntime);
            for k=1:nchannels
                data(j).avg.mom{k} = data_var.signal(k,:,j); %[1 time]
            end
        end
        
        % save data
        save(outfile,'data','-v7.3');
        params.force = true;
    else
        fprintf('source data exists: %s\n',outfile);
    end

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

%% params_lf_MLOCCDTWL_p10_l099

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l099';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MLOCCDTWL_p10_l098

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098';
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

params.analysis(k).lf = 'params_lf_MLOCCDTWL_p10_l098';
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

%% params_lf_MCMTLOCCDTWL2_mt5_p10_l099

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l099';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l099';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l099';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l099';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTLOCCDTWL2_mt5_p10_l098

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l098';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l098';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l098';
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

params.analysis(k).lf = 'params_lf_MCMTLOCCDTWL2_mt5_p10_l098';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

end
