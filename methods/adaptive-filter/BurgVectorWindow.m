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
        
        % buffer to save samples
        buffer;
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
            
            p = inputParser();
            addParameter(p,'nwindow',10,@isnumeric);
            p.parse(varargin{:});
            
            obj.order = order;
            obj.nchannels = channels;
            obj.nwindow = p.Results.nwindow;

            zeroMat = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat;
            obj.Kf = zeroMat;
            
            obj.name = sprintf('BurgVectorWindow C%d P%d W%d',...
                channels, order, obj.nwindow);
            
            obj.buffer = zeros(obj.nchannels, 1, obj.nwindow);
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
            
            % add the new measurement
            obj.buffer(:,:,1) = [];
            obj.buffer(:,:,end+1) = x;
            
            % compute parcor coefficients using Burg's method
            % needs [channels 1 samples]
            [pc, R0] = burgv(obj.buffer,obj.order);
            
            % convert parcor to rc
            [rcf,rcb,~,~] = pc2rcv(pc,R0);
            
            % save the rc coefficient, drop the first one
            obj.Kf = -1*shiftdim(rcf(:,:,2:end),2);
            obj.Kb = -1*shiftdim(rcb(:,:,2:end),2);
            
        end
    end
end