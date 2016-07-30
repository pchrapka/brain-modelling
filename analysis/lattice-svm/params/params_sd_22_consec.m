function params = params_sd_22_consec()
% params for subject 22 with consecutive std, odd trials

[srcdir,~,~] = fileparts(mfilename('fullpath'));

params = [];
params.subject_id = 22;

params.conds(1).file = fullfile(srcdir,...
    ['../experiments/output-common/fb/'...
    'MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstdconsec-BPatchTriallcmvmom/'...
    'sourceanalysis.mat']);
params.conds(1).opt_func = 'params_al_std';

params.conds(2).file = fullfile(srcdir,...
    ['../experiments/output-common/fb/'...
    'MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGoddconsec-BPatchTriallcmvmom/'...
    'sourceanalysis.mat']);
params.conds(2).opt_func = 'params_al_odd';

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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400';
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


params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTQRDLSL1_mt3_p10_l099_n400

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
params.analysis(k).pd = 'params_pd_std_odd_tr70_te20';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt8_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_thresh1dot5';
params.analysis(k).pd = 'params_pd_std_odd_tr20_te10';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt8_p10_l099_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

%% params_lf_MCMTQRDLSL1_mt2_p10_l098_n400

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l09_n400';
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

params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt2_p10_l09_n400';
params.analysis(k).fm = 'params_fm_lattice_nothresh';
params.analysis(k).pd = '';
params.analysis(k).fd = '';
params.analysis(k).fv = {};
params.analysis(k).tt = {};
k = k+1;

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

%%%%%%%%%%%
%% Orders 8, 6, 4, 2

%% params_lf_MCMTQRDLSL1_mt5_p8_l098_n400
params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p8_l098_n400';
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

%% params_lf_MCMTQRDLSL1_mt5_p6_l098_n400
params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p6_l098_n400';
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
%% params_lf_MCMTQRDLSL1_mt5_p4_l098_n400
params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p4_l098_n400';
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

%% params_lf_MCMTQRDLSL1_mt5_p2_l098_n400
params.analysis(k).lf = 'params_lf_MCMTQRDLSL1_mt5_p2_l098_n400';
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

end