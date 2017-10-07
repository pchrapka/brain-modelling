classdef NuttallStrandMT
    
    properties (SetAccess = protected)
        % reflection coefficients
        Kb;
        Kf;
        
        % filter order
        order;
        
        % number of channels
        nchannels;
        
        % number of trials
        ntrials;
        
        % name
        name;
        
        % number of samples
        nsamples;
    end
    
    methods
        
        function obj = NuttallStrandMT(channels, order, ntrials, varargin)
            %NuttallStrandMT constructor for NuttallStrandMT
            %   NuttallStrandMT(channels, order, ...) creates a NuttallStrandMT object
            %
            %   channels (integer)
            %       number of channels
            %   order (integer)
            %       filter order
            %   ntrials (integer)
            %       number of trials
            %   
            %   Parameters
            %   ----------
            %   nsamples (integer)
            %       number of samples to use in batch update
            
            p = inputParser();
            addRequired(p,'channels', @(x) isnumeric(x) && isscalar(x));
            addRequired(p,'order', @(x) isnumeric(x) && isscalar(x));
            addRequired(p,'ntrials', @(x) isnumeric(x) && isscalar(x));
            addParameter(p,'nsamples',[],@(x) isnumeric(x) && isscalar(x));
            p.parse(channels,order,varargin{:});
            
            obj.order = order;
            obj.nchannels = channels;
            obj.ntrials = ntrials;
            obj.nsamples = p.Results.nsamples;

            zeroMat = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat;
            obj.Kf = zeroMat;
            
            if isempty(obj.nsamples)
                obj.name = sprintf('NuttallStrandMT C%d P%d',...
                    channels, order);
            else
                obj.name = sprintf('NuttallStrandMT C%d P%d N%d',...
                    channels, order, obj.nsamples);
            end
        end 
        
        function obj = normalize(obj, nsamples)
            % do nothing
        end
        
        function obj = update_batch(obj, x, varargin)
            %UPDATE_BATCH updates reflection coefficients
            %   UPDATE_BATCH(OBJ,X) updates the reflection coefficients
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
            
            if ~isequal(size(x), [obj.nchannels obj.ntrials])
                error([mfilename ':update_batch'],...
                    'samples do not match filter size:\n  channels: %d\n  trials: %d',...
                    obj.nchannels, obj.ntrials);
            end
            
            if ~isempty(obj.nsamples)
                % select a smaller subset of samples
                x = x(:,:,1:obj.nsamples);
            end
            
            % compute parcor coefficients using Nuttall Strand method
            [~,rcf,rcb,~] = nuttall_strand(permute(x,[3,1,2]),obj.order);
            
            % save the rc coefficient, drop the first one            
            obj.Kf = rcarrayformat(reshape(rcf,[obj.nchannels obj.nchannels obj.order]),'format',1);
            obj.Kb = rcarrayformat(reshape(rcb,[obj.nchannels obj.nchannels obj.order]),'format',1);
            
        end
    end
end