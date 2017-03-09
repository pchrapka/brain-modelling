classdef BurgVectorWindow
    
    properties (SetAccess = protected)
        % reflection coefficients
        Kb;
        Kf;
        
        % filter order
        order;
        
        % number of channels
        nchannels;
        
        % name
        name;
        
        % number of samples per window
        nwindow;
        
        % number of trials
        ntrials;
        
        % buffer to save samples
        buffer;
        % sample count
        count = 1;
    end
    
    methods
        
        function obj = BurgVectorWindow(channels, order, varargin)
            %BurgVectorWindow constructor for BurgVector
            %   BurgVectorWindow(ORDER, LAMBDA) creates a BurgVector object
            %
            %   channels (integer)
            %       number of channels
            %   order (integer)
            %       filter order
            %   
            %   Parameters
            %   ----------
            %   nwindow (integer)
            %       number of samples to use for each window
            %   ntrials (integer)
            %       number of trials
            
            p = inputParser();
            addParameter(p,'nwindow',10,@(x) isnumeric(x) && isscalar(x));
            addParameter(p,'ntrials',1,@(x) isnumeric(x) && isscalar(x));
            p.parse(varargin{:});
            
            obj.order = order;
            obj.nchannels = channels;
            obj.nwindow = p.Results.nwindow;
            obj.ntrials = p.Results.ntrials;

            zeroMat = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat;
            obj.Kf = zeroMat;
            
            if obj.ntrials > 1
                obj.name = sprintf('BurgVectorWindow C%d P%d W%d T%d',...
                    channels, order, obj.nwindow, obj.ntrials);
            else
                obj.name = sprintf('BurgVectorWindow C%d P%d W%d',...
                    channels, order, obj.nwindow);
            end
            
            obj.buffer = zeros(obj.nchannels, obj.ntrials, obj.nwindow);
        end 
        
        function obj = update(obj, x, varargin)
            %UPDATE updates reflection coefficients
            %   UPDATE(OBJ,X) updates the reflection coefficients
            %   using the measurement X
            %
            %   Input
            %   -----
            %   x (matrix)
            %       new batch of measurements, the vector has
            %       the size [channels trials samples]
            %
            %   Parameters
            %   ----------
            %   verbosity (integer, default = 0)
            %       vebosity level, options: 0 1 2 3
            
            inputs = inputParser();
            params_verbosity = [0 1 2 3];
            addParameter(inputs,'verbosity',0,@(x) any(find(params_verbosity == x)));
            parse(inputs,varargin{:});
            
            % check sample size
            if ~isequal(size(x,1), obj.nchannels)
                error([mfilename ':update'],...
                    'samples do not match filter channels: %d %d',...
                    size(x,1), obj.nchannels);
            end
            
            % check trial size
            if ~isequal(size(x,2), obj.ntrials)
                error([mfilename ':update'],...
                    'samples do not match filter trials: %d %d',...
                    size(x,2), obj.ntrials);
            end
            
            % add the new measurement
            obj.buffer(:,:,1) = [];
            obj.buffer(:,:,end+1) = x;
            obj.count = obj.count + 1;
            
            if obj.count < obj.nwindow
                % wait until we have a minimum number of samples
                return;
            end
            
            zeroMat = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat;
            obj.Kf = zeroMat;
            
            for i=1:obj.ntrials
                % compute parcor coefficients using Burg's method
                % needs [channels 1 samples]
                [pc, R0] = burgv(obj.buffer(:,i,:),obj.order);
                
                % convert parcor to rc
                [rcf,rcb,~,~] = pc2rcv(pc,R0);
                
                % save the rc coefficient, drop the first one
                obj.Kf = obj.Kf + -1*shiftdim(rcf(:,:,2:end),2);
                obj.Kb = obj.Kb + -1*shiftdim(rcb(:,:,2:end),2);
                
            end
            
            % take the average
            obj.Kf = obj.Kf/obj.ntrials;
            obj.Kb = obj.Kb/obj.ntrials;
            
        end
    end
end