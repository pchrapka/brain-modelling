function obj = process_default(obj)

switch obj.config.mode
    case 'continuous'
        obj.process_preprocessing('PreDefineTrial',true);
        obj.process_redefinetrial();
        
    case 'trial'
        obj.process_definetrial();
        obj.process_preprocessing('postDefineTrial',true);
        
    otherwise
        fprintf('add mode field to config with either continuous or trial\n');
        fprintf('continuous - preprocesses the data and then splits them into trials\n');
        fprintf('trial - splits the data into trials and then preprocesses it\n');
        error('missing preprocessing mode');
end

% ft_rejectartifact
% optional
obj.process_artifact();

% ft_timelockanalysis
obj.process_timelock();

end