function obj = process_preprocessing(obj,varargin)

p = inputParser();
addParameter(p,'PreDefineTrial',false,@islogical);
parse(p,varargin{:});

if p.Results.PreDefineTrial
    if obj.check_file(obj.preprocessed)
        cfg = obj.config.ft_preprocessing;
        % needs dataset field in this case
        
        % preprocess data
        data = ft_preprocessing(cfg);
        save(obj.preprocessed, 'data','-v7.3');
        clear data;
    else
        fprintf('%s: skipping ft_preprocessing, already exists\n',...
            strrep(class(obj),'ftb.',''));
    end
    
else
    if obj.check_file(obj.preprocessed)
        % load output of ft_definetrial
        cfgdef = ftb.util.loadvar(obj.definetrial);
        % copy fields from obj.config.ft_preprocessing
        cfg = copyfields(obj.config.ft_preprocessing, cfgdef,...
            fieldnames(obj.config.ft_preprocessing));
        
        % preprocess data
        data = ft_preprocessing(cfg);
        save(obj.preprocessed, 'data','-v7.3');
        clear data;
    else
        fprintf('%s: skipping ft_preprocessing, already exists\n',...
            strrep(class(obj),'ftb.',''));
    end
end

end