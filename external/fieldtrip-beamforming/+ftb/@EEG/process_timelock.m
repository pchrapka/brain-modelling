function obj = process_timelock(obj)

% ft_timelockanalysis
if obj.check_file(obj.timelock)
    cfgin = obj.config.ft_timelockanalysis;
    if obj.check_file(obj.rejectartifact)
        cfgin.inputfile = obj.rejectartifact;
    else
        cfgin.inputfile = obj.preprocessed;
    end
    cfgin.outputfile = obj.timelock;
    
    ft_timelockanalysis(cfgin);
    % FIXME missing save?
    warning('i think i''m missing something here');
else
    fprintf('%s: skipping ft_timelockanalysis, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end