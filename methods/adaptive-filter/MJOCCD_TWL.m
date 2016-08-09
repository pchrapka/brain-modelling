classdef MJOCCD_TWL
    %MJOCCD_TWL Joint Multichannel Online Cyclic Coordinate Descent Time Weighted Lasso
    %   Based on Algorithm 3 from 
    %   D. Angelosante, J. A. Bazerque, and G. B. Giannakis, “Online
    %   Adaptive Estimation of Sparse Signals: Where RLS Meets the -Norm,”
    %   IEEE Transactions on Signal Processing, vol. 58, no. 7, pp.
    %   3436–3447, Jul. 2010.

    
    properties
        % number of regressors
        nregressors;
        % number of channels
        nchannels;
        
        % filter order
        order;
        % regularization parameter
        gamma;
        % forgetting factor
        lambda;
        
        % regression vector, aka past samples
        h;
        r;
        R;
        % AR estimate
        x;
        % AR estimate reshaped [order, channels, channels]
        A;
        
        % name
        name
    end
    
    methods
        function obj = MJOCCD_TWL(channels,order,varargin)
            %MJOCCD_TWL
            %   MJOCCD_TWL(channels,order,...)
            %   
            %   Inputs
            %   ------
            %   channels
            %       number of channels
            %   order
            %       filter order
            %
            %   Parameters
            %   ----------
            %   lambda (default = 0.99)
            %       forgetting factor
            %   gamma (default = 1.2);
            %       regularization parameter
            
            p = inputParser;
            addRequired(p,'channels');
            addRequired(p,'order');
            addParameter(p,'lambda',0.99);
            addParameter(p,'gamma',1.2);
            parse(p,channels,order,varargin{:});
            
            obj.order = p.Results.order;
            obj.nchannels = p.Results.channels;
            obj.nregressors = obj.order*obj.nchannels^2;
            obj.gamma = p.Results.gamma;
            obj.lambda = p.Results.lambda;
            obj.name = sprintf('MJOCCD_TWL C%d P%d lambda=%0.2f gamma=%0.2f',...
                obj.nchannels, obj.order, obj.lambda, obj.gamma);
            
            zeroVec = zeros(obj.nregressors,1);
            obj.h = zeros(obj.nchannels*obj.order,1);
            obj.r = zeroVec;
            obj.x = zeroVec;
            obj.R = eye(obj.nchannels*obj.order);
            obj.A = zeros(obj.order,obj.nchannels,obj.nchannels);
        end
        
        function obj = update(obj, y, varargin)
            %UPDATE updates reflection coefficients
            %   UPDATE(OBJ,Y) updates the reflection coefficients using the
            %   measurement X
            %
            %   Input
            %   -----
            %   y (vector)
            %       new measurements at current iteration, the vector has
            %       the size [channels 1]
            %
            %   Parameters
            %   ----------
            %   verbosity (integer, default = 0)
            %       vebosity level, options: 0 1 2 3
            
            inputs = inputParser();
            params_verbosity = [0 1 2 3];
            addParameter(inputs,'verbosity',0,@(x) any(find(params_verbosity == x)));
            parse(inputs,varargin{:});
            
            if ~isequal(size(y), [obj.nchannels 1])
                error([mfilename ':update'],...
                    'samples do not match filter channels: %d %d',...
                    size(y,1), obj.nchannels);
            end
            
            H = kron(eye(obj.nchannels),obj.h);
            % update R before kronecker expansion
            R_new = obj.lambda*obj.R + obj.h*obj.h';
            % expand R using kronecker product
            R_full = kron(eye(obj.nchannels),R_new);
            
            x_new = obj.x;
            
            % eq 8
            r_new = obj.lambda*obj.r + H*y;
            
            for p=1:obj.nregressors
                idx = true(obj.nregressors,1);
                idx(p) = false;
                
                % eq 18
                rp = r_new(p) - R_full(p,idx)*x_new(idx);
                % NOTE I think there's an error in Algorithm 3 in the paper
                % It says to use obj.x instead of x_new
                
                % eq 19
                x_new(p) = sign(rp)/R_full(p,p)*max((abs(rp) - obj.gamma),0);
            end
            
            % save vars
            obj.x = x_new;
            obj.r = r_new;
            obj.R = R_new;
            
            fprintf('x:');
            fprintf('%0.2f ',obj.x);
            fprintf('\n');
            
            % save new measurement
            h_new = circshift(obj.h,obj.nchannels);
            h_new(1:obj.nchannels) = y;
            obj.h = h_new;
            
            % reshape to 3d matrix
            obj.A = reshape(obj.x,obj.nchannels,obj.order,obj.nchannels);
            obj.A = shiftdim(obj.A,1);
            
        end
    end
    
end

