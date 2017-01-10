function obj = process_redefinetrial(obj)

% ft_definetrial
if obj.check_file(obj.definetrial)
    % define the trial
    cfg = ft_definetrial(obj.config.ft_definetrial);
    data = cfg;
    save(obj.definetrial, 'data');
    
    datain = ftb.util.loadvar(obj.preprocessed);
    data = ft_redefinetrial(cfg, datain);
    save(obj.preprocessed, 'data','-v7.3');
else
    fprintf('%s: skipping ft_definetrial, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end