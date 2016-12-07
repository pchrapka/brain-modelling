classdef BurgVector
    
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
        
        function obj = BurgVector(channels, order, varargin)
            %BurgVector constructor for BurgVector
            %   BurgVector(channels, order, ...) creates a BurgVector object
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
            addParameter(p,'nsamples',[],@isnumeric);
            p.parse(varargin{:});
            
            obj.order = order;
            obj.nchannels = channels;
            obj.nsamples = p.Results.nsamples;

            zeroMat = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat;
            obj.Kf = zeroMat;
            
            if isempty(obj.nsamples)
                obj.name = sprintf('BurgVector C%d P%d',...
                    channels, order);
            else
                obj.name = sprintf('BurgVector C%d P%d N%d',...
                    channels, order, obj.nsamples);
            end
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
            
            if ~isempty(obj.nsamples)
                % select a smaller subset of samples
                x = x(:,:,1:obj.nsamples);
            end
            
            % compute parcor coefficients using Burg's method
            [pc, R0] = burgv(x,obj.order);
            
            % convert parcor to rc
            [rcf,rcb,~,~] = pc2rcv(pc,R0);
            
            % save the rc coefficient, drop the first one            
            obj.Kf = -1*rcarrayformat(rcf(:,:,2:end),'format',1);
            obj.Kb = -1*rcarrayformat(rcb(:,:,2:end),'format',1);
            
        end
    end
end