function obj = process_default(obj)

% ft_definetrial
if obj.check_file(obj.definetrial)
    % define the trial
    data = ft_definetrial(obj.config.ft_definetrial);
    save(obj.definetrial, 'data');
else
    fprintf('%s: skipping ft_definetrial, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

% ft_preprocessing
if obj.check_file(obj.preprocessed)
    % load output of ft_definetrial
    cfgdef = ftb.util.loadvar(obj.definetrial);
    % copy fields from obj.config.ft_preprocessing
    cfg = copyfields(obj.config.ft_preprocessing, cfgdef,...
        fieldnames(obj.config.ft_preprocessing));
    
    % preprocess data
    data = ft_preprocessing(cfg);
    save(obj.preprocessed, 'data','-v7.3');
    clear data;
else
    fprintf('%s: skipping ft_preprocessing, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

% ft_rejectartifact
% optional
if isfield(obj.config, 'ft_rejectartifact')
    if obj.check_file(obj.rejectartifact)
        % detect artifacts
        funcs_artifact = {...
            'ft_artifact_clip',...
            'ft_artifact_ecg',...
            'ft_artifact_threshold',...
            'ft_artifact_eog',...
            'ft_artifact_jump',...
            'ft_artifact_muscle',...
            'ft_artifact_zvalue',...
            };
        
        % load output of ft_definetrial
        cfgdef = ftb.util.loadvar(obj.definetrial);
        
        artifacts = [];
        artifacts.name = '';
        artifacts.value = [];
        for i=1:length(funcs_artifact)
            % run through all specified artifact detection functions
            ft_func = funcs_artifact{i};
            if isfield(obj.config,ft_func)
                cfg = obj.config.(ft_func);
                cfg.inputfile = obj.preprocessed;
                cfg.trl = cfgdef.trl;
                
                fh = str2func(ft_func);
                [~,artifacts(i).value] = fh(cfg);
                artifacts(i).name = strrep(ft_func,'ft_artifact_','');
            end
        end
        
        % rejectartifact
        cfg = obj.config.rejectartifact;
        cfg.inputfile = obj.preprocessed;
        % add artifactual trials for rejection
        for i=1:length(artifacts)
            cfg.artfctdef.(artifacts(i).name).artifact = artifacts(i).value;
        end
        
        data = ft_rejectartifact(cfg);
        save(obj.rejectartifact, 'data','-v7.3');
        clear data;
    else
        fprintf('%s: skipping ft_rejectartifact, already exists\n',...
            strrep(class(obj),'ftb.',''));
    end
end

% ft_timelockanalysis
if obj.check_file(obj.timelock)
    cfgin = obj.config.ft_timelockanalysis;
    cfgin.inputfile = obj.preprocessed;
    cfgin.outputfile = obj.timelock;
    
    ft_timelockanalysis(cfgin);
    % FIXME missing save?
    warning('i think i''m missing something here');
else
    fprintf('%s: skipping ft_timelockanalysis, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end