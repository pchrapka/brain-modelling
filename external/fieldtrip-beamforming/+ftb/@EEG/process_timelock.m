function obj = process_timelock(obj)

% ft_timelockanalysis
if obj.check_file(obj.timelock)
    % set up cfg
    cfg = obj.config.ft_timelockanalysis;
    
    % check if we should data after artifact rejection
    if obj.check_file(obj.rejectartifact)
        cfg.inputfile = obj.rejectartifact;
    else
        cfg.inputfile = obj.preprocessed;
    end
    cfg.outputfile = obj.timelock;
    
    ft_timelockanalysis(cfg);
else
    fprintf('%s: skipping ft_timelockanalysis, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end