classdef EEGPrePost < ftb.EEG
    %EEGPrePost Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        pre;    % ftb.EEG
        post;   % ftb.EEG
        % original EEG properties - describes full segment
    end
    
    methods
        function obj = EEGPrePost(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Object)
            %       previous analysis step
            
            % use EEG constructor
            obj@ftb.EEG(params,name);
            obj.prefix = 'EEGPP';
            
            % create pre, post objects
            obj.pre = ftb.EEG(obj.config.pre,'pre');
            obj.post = ftb.EEG(obj.config.post,'post');
            % remove pre, post configs
            obj.config = rmfield(obj.config,'pre');
            obj.config = rmfield(obj.config,'post');
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.Leadfield') || isa(x,'ftb.EEGMMN'));
            parse(p,prev);
            
            % set the previous step
            obj.prev = p.Results.prev;
            obj.pre.prev = p.Results.prev;
            obj.post.prev = p.Results.prev;
        end
        
        function obj = init(obj,out_folder)
            
            % call EEG init on main object
            init@ftb.EEG(obj,out_folder);
            
            % create folder for analysis step, name accounts for dependencies
            out_folder2 = fullfile(out_folder, obj.get_name());
            if ~exist(out_folder2,'dir')
                mkdir(out_folder2)
            end        
            
            % init EEG objects
            obj.pre.init(out_folder2);
            obj.pre.definetrial = '';
            obj.post.init(out_folder2);
            obj.post.definetrial = '';
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % process main object, i.e. process entire segment
            process@ftb.EEG(obj);
            
            % process pre
            obj.process_redefine(obj.pre);
            % process post
            obj.process_redefine(obj.post);
            
        end
        
    end
    
    methods(Access = private)
        function obj = process_redefine(obj,eegObj)
            
            % ft_redefinetrial
            if obj.check_file(eegObj.preprocessed)
                % copy config
                cfgin = eegObj.config.ft_redefinetrial;
                cfgin.inputfile = obj.preprocessed;
                cfgin.outputfile = eegObj.preprocessed;
                
                ft_redefinetrial(cfgin);
            else
                fprintf('%s: skipping ft_redefinetrial %s, already exists\n',...
                    mfilename,eegObj.name);
            end
            
            % ft_timelockanalysis
            if obj.check_file(eegObj.timelock)
                cfgin = eegObj.config.ft_timelockanalysis;
                cfgin.inputfile = eegObj.preprocessed;
                cfgin.outputfile = eegObj.timelock;
                
                ft_timelockanalysis(cfgin);
            else
                fprintf('%s: skipping ft_timelockanalysis %s, already exists\n',...
                    mfilename,eegObj.name);
            end
        end
    end
end

