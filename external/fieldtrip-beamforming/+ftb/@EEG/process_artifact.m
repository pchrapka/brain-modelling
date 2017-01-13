function obj = process_artifact(obj)

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
        
        % figure out input file
        switch obj.config.mode
            case 'continuous'
                inputfile = obj.redefinetrial;
            case 'trial'
                inputfile = obj.preprocessed;
            otherwise
                error('missing output for mode %s',obj.config.mode);
        end
        
        artifacts = [];
        artifacts.name = '';
        artifacts.value = [];
        for i=1:length(funcs_artifact)
            % run through all specified artifact detection functions
            ft_func = funcs_artifact{i};
            if isfield(obj.config,ft_func)
                cfg = obj.config.(ft_func);
                cfg.inputfile = inputfile;
                cfg.trl = cfgdef.trl;
                
                fh = str2func(ft_func);
                [~,artifacts(i).value] = fh(cfg);
                artifacts(i).name = strrep(ft_func,'ft_artifact_','');
            end
        end
        
        % ft_rejectartifact
        cfg = obj.config.ft_rejectartifact;
        cfg.inputfile = inputfile;
        
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

end