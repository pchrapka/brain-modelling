classdef NuttallStrand
    
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
        
        % number of samples
        nsamples;
    end
    
    methods
        
        function obj = NuttallStrand(channels, order, varargin)
            %NuttallStrand constructor for NuttallStrand
            %   NuttallStrand(channels, order, ...) creates a NuttallStrand object
            %
            %   channels (integer)
            %       number of channels
            %   order (integer)
            %       filter order
            %   
            %   Parameters
            %   ----------
            %   nsamples (integer)
            %       number of samples to use in batch update
            
            p = inputParser();
            addRequired(p,'channels', @(x) isnumeric(x) && isscalar(x));
            addRequired(p,'order', @(x) isnumeric(x) && isscalar(x));
            addParameter(p,'nsamples',[],@(x) isnumeric(x) && isscalar(x));
            p.parse(channels,order,varargin{:});
            
            obj.order = order;
            obj.nchannels = channels;
            obj.nsamples = p.Results.nsamples;

            zeroMat = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat;
            obj.Kf = zeroMat;
            
            if isempty(obj.nsamples)
                obj.name = sprintf('NuttallStrand C%d P%d',...
                    channels, order);
            else
                obj.name = sprintf('NuttallStrand C%d P%d N%d',...
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
            
            % check sample size
            if ~isequal(size(x,1), obj.nchannels)
                error([mfilename ':update_batch'],...
                    'samples do not match filter channels: %d %d',...
                    size(x,1), obj.nchannels);
            end
            
            % check trials
            if ~isequal(size(x,2),1)
                error([mfilename ':update_batch'],...
                    'too many trials %d', size(x,2));
            end
            
            if ~isempty(obj.nsamples)
                % select a smaller subset of samples
                x = x(:,:,1:obj.nsamples);
            end
            
            % compute parcor coefficients using Nuttall Strand method
            [~,rcf,rcb,~] = nuttall_strand(squeeze(x)',obj.order);
            
            % save the rc coefficient, drop the first one            
            obj.Kf = rcarrayformat(reshape(rcf,[obj.nchannels obj.nchannels obj.order]),'format',1);
            obj.Kb = rcarrayformat(reshape(rcb,[obj.nchannels obj.nchannels obj.order]),'format',1);
%             % take transpose for each order
%             obj.Kf = permute(obj.Kf,[1 3 2]);
%             obj.Kb = permute(obj.Kb,[1 3 2]);
            
        end
    end
end