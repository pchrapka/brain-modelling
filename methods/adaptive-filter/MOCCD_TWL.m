classdef MOCCD_TWL < handle
    %MOCCD_TWL Multichannel Online Cyclic Coordinate Descent Time Weighted Lasso
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
        function obj = MOCCD_TWL(channels,order,varargin)
            %MOCCD_TWL
            %   MOCCD_TWL(channels,order,...)
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
            obj.nregressors = obj.order*obj.nchannels;
            obj.gamma = p.Results.gamma;
            obj.lambda = p.Results.lambda;
            obj.name = sprintf('MOCCD_TWL C%d P%d lambda=%0.2f gamma=%0.2f',...
                obj.nchannels, obj.order, obj.lambda, obj.gamma);
            
            zeroVec = zeros(obj.nregressors,1);
            zeroMat = zeros(obj.nchannels,obj.nregressors);
            obj.h = zeroVec;
            obj.r = zeroMat;
            obj.x = zeroMat;
            obj.R = eye(obj.nregressors);
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
            
            R_new = obj.lambda*obj.R + obj.h*obj.h';
            
            for ch=1:obj.nchannels
                x_new = obj.x(ch,:)';
                
                % eq 8
                r_new = obj.lambda*obj.r(ch,:)' + y(ch)*obj.h;
                
                for p=1:obj.nregressors
                    idx = true(obj.nregressors,1);
                    idx(p) = false;
                    
                    % eq 18
                    rp = r_new(p) - R_new(p,idx)*x_new(idx);
                    % NOTE I think there's an error in Algorithm 3 in the paper
                    % It says to use obj.x instead of x_new
                    
                    % eq 19
                    x_new(p) = sign(rp)/R_new(p,p)*max((abs(rp) - obj.gamma),0);
                end
                
                % save vars
                obj.x(ch,:) = x_new;
                obj.r(ch,:) = r_new;
                
                fprintf('ch%02d x:',ch);
                fprintf('%0.2f ',obj.x(ch,:));
                fprintf('\n');
            end
            
            % save vars
            obj.R = R_new;
            
            % save new measurement
            h_new = circshift(obj.h,obj.nchannels);
            h_new(1:obj.nchannels) = y;
            obj.h = h_new;
            
            % reshape to 3d matrix
            obj.A = reshape(obj.x,obj.nchannels,obj.nchannels,obj.order);
            obj.A = shiftdim(obj.A,2);
            
        end
    end
    
end

