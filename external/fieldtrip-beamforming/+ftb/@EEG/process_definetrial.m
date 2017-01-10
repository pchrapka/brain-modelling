function obj = process_definetrial(obj)

% ft_definetrial
if obj.check_file(obj.definetrial)
    % define the trial
    data = ft_definetrial(obj.config.ft_definetrial);
    save(obj.definetrial, 'data');
else
    fprintf('%s: skipping ft_definetrial, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end