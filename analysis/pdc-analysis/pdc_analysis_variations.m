function pdc_analysis_variations(params,varargin)

p = inputParser();
addRequired(p,'params',@isstruct);
addParameter(p,'flag_run',true,@islogical);
addParameter(p,'flag_tune',false,@islogical);
addParameter(p,'flag_tune_order',false,@islogical);
addParameter(p,'flag_tune_lambda',false,@islogical);
addParameter(p,'flag_tune_gamma',false,@islogical);
addParameter(p,'flag_bootstrap',false,@islogical);
parse(p,params,varargin{:});


for i=1:length(params)
    
    stimulus = 'std';
    subject = 3;
    deviant_percent = 10;
    
    [pipeline,outdirbase] = eeg_processall_andrew(...
        stimulus,subject,deviant_percent,params(i).patch_type);
    
    % separate following output based on patch model
    outdir = fullfile(outdirbase,params(i).patch_type);
    
    if p.Results.flag_tune
        if p.Results.flag_tune_order
            params2 = params(i);
            params2 = rmfield(params2,'metrics');
            
            params2.order = 1:14;
            params2.lambda = 0.99;
            params2.gamma = 1e-2;
            
            params2.plot = true;
            params2.plot_crit = 'ewaic';
            params2.plot_orders = params2.order;
            
            params_func = struct2namevalue(params2);
            tune_model_order(pipeline,outdir,params_func{:});
        end
        
        if p.Results.flag_tune_lambda
            params2 = params(i);
            params2 = rmfield(params2,'metrics');
            
            params2.order = 6;
            params2.lambda = [0.9:0.02:0.98 0.99];
            params2.gamma = 1e-2;
            
            params2.plot = true;
            params2.plot_crit = 'normtime';
            params2.plot_orders = [1 2 3 4];
            
            params_func = struct2namevalue(params2);
            tune_lambda(pipeline,outdir,params_func{:});
        end
        
        if p.Results.flag_tune_gamma
            params2 = params(i);
            params2 = rmfield(params2,'metrics');
            
            params2.order = 6;
            params2.lambda = 0.99;
            params2.gamma = [1e-4 1e-3 1e-2 0.1 1 10];
            
            params2.plot = true;
            params2.plot_crit = 'normtime';
            params2.plot_orders = [1 2 3 4];
            
            params_func = struct2namevalue(params2);
            tune_gamma(pipeline,outdir,params_func{:});
        end
        
    end
    
    if p.Results.flag_run
        % copy params
        params2 = params(i);
        % remove metrics field
        params2 = rmfield(params2,'metrics');
        
        % loop over metrics
        for j=1:length(params(i).metrics)
            
            % select lf params
            params_lf = copyfields(params2,[],...
                {'ntrials','order','lambda','gamma','normalization','envelope'});
            params_lf.tracefields = {'Kf','Kb','Rf','ferror'};
            % added Rf for info criteria
            % added ferror for bootstrap
            params_func = struct2namevalue(params_lf);
            lf_files = lf_analysis_main(pipeline, outdir, params_func{:});
            
            % select pdc params
            params_pdc = copyfields(params2,[],...
                {'metric','patch_type','envelope'});
            % change metric
            params_pdc.metric = params(i).metrics{j};
            params_func = struct2namevalue(params_pdc);
            
            % TODO add downsample as a parameter
            eeg_file = fullfile(outdirbase,'fthelpers.ft_phaselocked.mat');
            pdc_analysis_main(pipeline, lf_files, eeg_file, params_func{:});
            
            if p.Results.flag_bootstrap
                pdc_params = {'downsample',4,'metric',params(i).metrics{j}};
                pdc_sig_file = pdc_bootstrap(...
                    lf_files{1},'nresamples',100,'alpha',0.05,'pdc_params',pdc_params);
                
                % TODO plot with significance threshold
            end
        end
    end
end

end