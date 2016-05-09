classdef OCD_TWL < handle
    %OCD_TWL Online Coordinate Descent Time Weighted Lasso
    %   Implementation of Algorithm 1 from 
    %   D. Angelosante, J. A. Bazerque, and G. B. Giannakis, “Online
    %   Adaptive Estimation of Sparse Signals: Where RLS Meets the -Norm,”
    %   IEEE Transactions on Signal Processing, vol. 58, no. 7, pp.
    %   3436–3447, Jul. 2010.
    
    properties
        % filter order
        order;
        % regularization parameter
        lambda;
        % forgetting factor
        beta;
        
        % regression vector, aka past samples
        h;
        r;
        R;
        x;
        iteration;
        
        % number of channels
        nchannels;
        
        % name
        name
    end
    
    methods
        function obj = OCD_TWL(order,lambda,beta)
            obj.order = order;
            obj.nchannels = 1;
            obj.lambda = lambda;
            obj.beta = beta;
            obj.name = sprintf('OCD_TWL C%d P%d beta=%0.2f lambda=%0.2f',...
                obj.nchannels, order, beta, lambda);
            
            zeroVec = zeros(order,1);
            obj.h = zeroVec;
            obj.r = zeroVec;
            obj.x = zeroVec;
            obj.R = eye(order);
            obj.iteration = 0;
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
            
            % update iteration count
            obj.iteration = obj.iteration + 1;
            
            % eq 8
            r_new = obj.beta*obj.r + y*obj.h;
            R_new = obj.beta*obj.R + obj.h*obj.h';
            
            % determine which coordinate to update
            p = mod(obj.iteration,obj.order) + 1;
            
            idx = true(obj.order,1);
            idx(p) = false;
            
            % copy old estimate
            x_new = obj.x;
            
            % eq 18
            rp = r_new(p) - R_new(p,idx)*obj.x(idx);
            % eq 19
            x_new(p) = sign(rp)/R_new(p,p)*max((abs(rp) - obj.lambda),0);
            
            % save vars
            obj.x = x_new;
            obj.r = r_new;
            obj.R = R_new;
            
            fprintf('x:');
            fprintf('%0.2f ',obj.x);
            fprintf('\n');
            
            % save new measurement
            h_new = circshift(obj.h,1);
            h_new(1) = y;
            obj.h = h_new;
        end
    end
    
end

