%% explore_features

% code to run analysis pipeline
% pipeline = build_pipeline_lattice_svm('params_sd_22');
% pipeline.run();

params_subject = 'params_sd_22';
params_name = {...
    'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt8_p10_l099_n400',...
    };

explore_features_lattice_svm(params_subject,params_name);

%% 
% code to run analysis pipeline
% pipeline = build_pipeline_lattice_svm('params_sd_22_consec');
% pipeline.run();

params_subject = 'params_sd_22_consec';
params_name = {...
    'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400',...
    'params_lf_MCMTQRDLSL1_mt2_p10_l09_n400',...
    'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l098_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l09_n400',...
    'params_lf_MCMTQRDLSL1_mt8_p10_l099_n400',...
    };

explore_features_lattice_svm(params_subject,params_name);