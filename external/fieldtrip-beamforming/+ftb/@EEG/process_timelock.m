function obj = process_timelock(obj)

% ft_timelockanalysis
if obj.check_file(obj.timelock)
    % set up cfg
    cfg = obj.config.ft_timelockanalysis;
    
    % check if we should use data after artifact rejection
    if obj.check_file(obj.rejectartifact)
        cfg.inputfile = obj.rejectartifact;
    else
        % figure out input file
        switch obj.config.mode
            case 'continuous'
                cfg.inputfile = obj.redefinetrial;
            case 'trial'
                cfg.inputfile = obj.preprocessed;
            otherwise
                error('missing output for mode %s',obj.config.mode);
        end
    end
    cfg.outputfile = obj.timelock;
    
    ft_timelockanalysis(cfg);
else
    fprintf('%s: skipping ft_timelockanalysis, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end