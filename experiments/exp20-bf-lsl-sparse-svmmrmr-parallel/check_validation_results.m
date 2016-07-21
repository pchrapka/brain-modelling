%% check_validation_results.m

% code to run analysis pipeline
% pipeline = build_pipeline_lattice_svm('params_sd_22');
% pipeline.run();

params_subject = 'params_sd_22';
params_name = {'params_lf_MLOCCDTWL_p10_l099_n400'};

print_results_lattice_svm(params_subject,params_name,'tofile',true);

%%

% code to run analysis pipeline
% pipeline = build_pipeline_lattice_svm('params_sd_22_consec');
% pipeline.run();

params_subject = 'params_sd_22_consec';
params_name = {...
    'params_lf_MLOCCDTWL_p10_l099_n400',...
    'params_lf_MLOCCDTWL_p10_l098_n400',...
    };

print_results_lattice_svm(params_subject,params_name,'tofile',true);
