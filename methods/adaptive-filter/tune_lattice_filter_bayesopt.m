function [opt,labels] = tune_lattice_filter_bayesopt(outdir,varargin)

p = inputParser();
addRequired(p,'outdir',@ischar);
addRequired(p,'tune_file',@ischar);
addParameter(p,'opt_mode','',@ischar);
addParameter(p,'filter_params',[],@isstruct);
parse(p,outdir,varargin{:});

idx_start = floor(nsamples*0.05);
idx_end = ceil(nsamples*0.95);

switch p.Results.opt_mode
    case 'MCMTLOCCD_TWL4_gamma'
        filter_params = {...
            p.Results.filter_params.nchannels,...
            p.Results.filter_params.norder,...
            p.Results.filter_params.ntrials,...
            'lambda',p.Results.filter_params.lambda,...
            'gamma',x(1)};
        
        func_bayes = @(x) tune_lattice_filter(...
            tune_file,...
            outdir,...
            'filter','MCMTLOCCD_TWL4',...
            'filter_params',filter_params,...
            'run_options',{'warmup_noise', false,'warmup_data', false},...
            'criteria','normtime',...
            'criteria_samples',[idx_start idx_end]);
        
        n = 1;
        ub = [10]; %[gamma]
        lb = zeros(n,1);
        labels = {'gamma'};
    otherwise
        error('not implemented %s',p.Results.opt_mode);
end

[~,datadir,~] = fileparts(tune_file);
params_bayes = [];
params_bayes.n_iterations = 30;
params_bayes.n_init_samples = 10;
params_bayes.verbose_level = 1;
params_bayes.log_filename = 'matbopt.log';
params_bayes.load_filename= fullfile(outdir,datadir,'bayesopt.dat');
params_bayes.save_filename = fullfile(outdir,datadir,'bayesopt.dat');
if exist(params_bayes.save_filename,'file')
    params_bayes.load_save_flag = 3;
else
    params_bayes.load_save_flag = 2;
end
[opt,~] = bayesoptcont(func_bayes, n, params_bayes, lb, ub);

for i=1:length(labels)
    fprintf('set %s to %g\n',labels{i},opt(i));
end

end