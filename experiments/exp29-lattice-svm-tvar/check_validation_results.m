%% check_validation_results.m


% code to run analysis pipeline
% pipeline = build_pipeline_lattice_svm('params_sd_tvar_p8_ch13');
% pipeline.run();

params_subject = 'params_sd_tvar_p8_ch13';
params_name = {...
    'params_lf_MQRDLSL2_p10_l099_n400',...
    'params_lf_MLOCCDTWL_p10_l099_n400',...
    'params_lf_MLOCCDTWL_p10_l098_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l098_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l09_n400',...
    };

print_results_lattice_svm(params_subject,params_name,'tofile',true);