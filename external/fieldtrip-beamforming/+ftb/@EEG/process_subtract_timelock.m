function obj = process_subtract_timelock(obj)

% not using definetrial
% not using preprocessed

% get all EEG deps
eeg_steps = obj.get_dep('ftb.EEG','all');
if length(eeg_steps) > 2
    error(['ftb:' mfilename],...
        'too many EEG objects %d',length(eeg_steps));
end


% % ft_preprocessing
% if obj.check_file(obj.preprocessed)
%     eegObj1 = eeg_steps(1);
%     eegObj2 = eeg_steps(2);
%     
%     eeg_preprocessed = ftb.util.loadvar(eegObj1.preprocessed);
%     
%     eeg1 = ftb.util.loadvar(eegObj1.timelock);
%     eeg2 = ftb.util.loadvar(eegObj1.timelock);
%     
%     eeg_preprocessed
%     eegout.avg = eeg1.avg - eeg2.avg;
%     
%     % preprocess data
%     data = ft_preprocessing(cfg);
%     save(obj.preprocessed, 'data');
% else
%     fprintf('%s: skipping ft_preprocessing, already exists\n',...
%         mfilename);
% end

% ft_timelockanalysis
if obj.check_file(obj.timelock)
    eegObj1 = eeg_steps(1);
    eegObj2 = eeg_steps(2);
    
    % subtract the timelocked data
    eeg1 = ftb.util.loadvar(eegObj1.timelock);
    eeg2 = ftb.util.loadvar(eegObj2.timelock);
    
    fprintf('%s: subtracting: %s - %s\n', strrep(class(obj),'ftb.',''),...
        [eegObj1.prefix eegObj1.name], ...
        [eegObj2.prefix eegObj2.name]);
    
    % create output struct
    data = eeg1;
    data.avg = eeg1.avg - eeg2.avg;
    data = rmfield(data,'cov');
    save(obj.timelock, 'data');
    
    % compute covariance
    cfgin = obj.config.ft_timelockanalysis;
    cfgin.inputfile = obj.timelock;
    cfgin.outputfile = obj.timelock;
    
    ft_timelockanalysis(cfgin);
else
    fprintf('%s: skipping ft_timelockanalysis, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end