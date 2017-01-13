function obj = process_redefinetrial(obj)

% ft_definetrial
if obj.check_file(obj.definetrial)
    % define the trial
    data_definetrial = ft_definetrial(obj.config.ft_definetrial);
    data = data_definetrial;
    save(obj.definetrial, 'data');
    
    data_preprocessed = ftb.util.loadvar(obj.preprocessed);
    data = ft_redefinetrial(data_definetrial, data_preprocessed);
    save(obj.preprocessed, 'data','-v7.3');
else
    fprintf('%s: skipping ft_definetrial, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end