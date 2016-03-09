function obj = process_default(obj)

% ft_definetrial
if obj.check_file(obj.definetrial)
    % define the trial
    data = ft_definetrial(obj.config.ft_definetrial);
    save(obj.definetrial, 'data');
else
    fprintf('%s: skipping ft_definetrial, already exists\n',...
        mfilename);
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
    save(obj.preprocessed, 'data');
else
    fprintf('%s: skipping ft_preprocessing, already exists\n',...
        mfilename);
end

% ft_timelockanalysis
if obj.check_file(obj.timelock)
    cfgin = obj.config.ft_timelockanalysis;
    cfgin.inputfile = obj.preprocessed;
    cfgin.outputfile = obj.timelock;
    
    ft_timelockanalysis(cfgin);
else
    fprintf('%s: skipping ft_timelockanalysis, already exists\n',...
        mfilename);
end

end