classdef EEGMMN < ftb.EEG
    %EEGMMN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % other properties see ftb.EEG
    end
    
    methods
        function obj = EEGMMN(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Object)
            %       previous analysis step
            
            % use EEG constructor
            obj@ftb.EEG(params,name);
            obj.prefix = 'EEGMMN';
            
%             % TODO figure out from dependencies?
%             % or specify directly
%             % adding in forks complicates the dependency structure
%             p1 = inputParser;
%             addRequired(p1,'EEG1',@(x) isa(x,'ftb.EEG'));
%             addRequired(p1,'EEG2',@(x) isa(x,'ftb.EEG'));
%             parse(p1,obj.config.EEG);
%             obj.EEG1 = p1.Results.EEG1;
%             obj.EEG2 = p1.Results.EEG2;
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.EEG'));
            parse(p,prev);
            
            % set the previous step, aka Leadfield
            obj.prev = p.Results.prev;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
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
                eegObj1 = eeg_steps{1};
                eegObj2 = eeg_steps{2};
                
                % subtract the timelocked data
                eeg1 = ftb.util.loadvar(eegObj1.timelock);
                eeg2 = ftb.util.loadvar(eegObj2.timelock);
                
                fprintf('%s: subtracting: %s - %s\n', mfilename,...
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
                    mfilename);
            end
        end
    end
end

