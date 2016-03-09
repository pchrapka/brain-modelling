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
            nsteps = length(eeg_steps);
            if nsteps ~= 2
                if nsteps > 2
                    error(['ftb:' mfilename],...
                        'too many EEG objects %d',nsteps);
                else
                    error(['ftb:' mfilename],...
                        'not enough EEG objects %d',nsteps);
                end
            end
            
            % ft_timelockanalysis
            if obj.check_file(obj.timelock)
                eegObj1 = eeg_steps{1};
                eegObj2 = eeg_steps{2};
                
                % load timelocked data
                eeg1 = ftb.util.loadvar(eegObj1.timelock);
                eeg2 = ftb.util.loadvar(eegObj2.timelock);
                
                fprintf('%s: subtracting: %s - %s\n', mfilename,...
                    [eegObj1.prefix eegObj1.name], ...
                    [eegObj2.prefix eegObj2.name]);
                
                % create output struct
                data = eeg1;
                
                % subtract the timelocked data
                data.avg = eeg1.avg - eeg2.avg;
                
                % remove covariance field to recompute
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

