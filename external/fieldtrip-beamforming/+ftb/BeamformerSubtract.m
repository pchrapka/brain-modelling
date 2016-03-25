classdef BeamformerSubtract < ftb.Beamformer
    %BeamformerSubtract Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % see ftb.Beamformer
    end
    
    methods
        function obj = BeamformerSubtract(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Object)
            %       previous analysis step
            
            % use Beamformer constructor
            obj@ftb.Beamformer(params,name);
            obj.prefix = 'BSubtract';
            
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.Beamformer'));
            parse(p,prev);
            
            % set the previous step
            obj.prev = p.Results.prev;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % get all Beamformer deps
            steps = obj.get_dep('ftb.Beamformer','all');
            nsteps = length(steps);
            if nsteps ~= 2
                if nsteps > 2
                    error(['ftb:' mfilename],...
                        'too many Beamformer objects %d',nsteps);
                else
                    error(['ftb:' mfilename],...
                        'not enough Beamformer objects %d',nsteps);
                end
            end
            
            if obj.check_file(obj.sourceanalysis)
                bfObj1 = steps{1};
                bfObj2 = steps{2};
                
                % load sourceanalysis data
                bf1 = ftb.util.loadvar(bfObj1.sourceanalysis);
                bf2 = ftb.util.loadvar(bfObj2.sourceanalysis);
                
                fprintf('%s: subtracting: %s - %s\n',...
                    strrep(class(obj),'ftb.',''),...
                    [bfObj1.prefix bfObj1.name], ...
                    [bfObj2.prefix bfObj2.name]);
                
                % create output struct
                data = bf1;
                if isfield(data.avg,'mom')
                    data.avg = rmfield(data.avg,'mom');
                end
                
                % subtract the source analysis
                data.avg.pow = bf1.avg.pow - bf2.avg.pow;
                
                save(obj.sourceanalysis,'data');
            else
                fprintf('%s: skipping ft_sourceanalysis, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
        end
    end
    
end

