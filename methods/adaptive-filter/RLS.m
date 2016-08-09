classdef RLS
    %RLS Recursive Least Squares
    %   Implementation from 
    %   S. Haykin, Adaptive filter theory, 4th ed. 2002. p. 443


    
    properties
        % filter order
        order;
        % forgetting factor
        lambda;
        
        % regression vector, aka past samples
        h;
        % inverse of sample autocorrelation matrix
        P;
        % tap weight vector
        x;
        
        % number of channels
        nchannels;
        
        % name
        name
    end
    
    methods
        function obj = RLS(order,varargin)
            %RLS
            %   RLS(order,...)
            %   
            %   Inputs
            %   ------
            %   order
            %       filter order
            %
            %   Parameters
            %   ----------
            %   lambda (default = 0.99)
            %       forgetting factor
            
            p = inputParser;
            addRequired(p,'order');
            addParameter(p,'lambda',0.99);
            parse(p,order,varargin{:});
            
            obj.order = p.Results.order;
            obj.nchannels = 1;
            obj.lambda = p.Results.lambda;
            obj.name = sprintf('RLS C%d P%d lambda=%0.2f',...
                obj.nchannels, p.Results.order, p.Results.lambda);
            
            zeroVec = zeros(order,1);
            obj.h = zeroVec;
            obj.x = zeroVec;
            delta = 10; % small +ve constant for high SNR, large +ve constant for low SNR
            obj.P = delta^(-1)*eye(order);
        end
        
        function obj = update(obj, y, varargin)
            %UPDATE updates AR coefficients
            %   UPDATE(OBJ,Y) updates the AR coefficients using the
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
            
            k_lambda = obj.P*obj.h;
            k = k_lambda/(obj.lambda + obj.h'*k_lambda);
            eta = y - obj.x'*obj.h;
            P_new = (1/obj.lambda)*(obj.P - k*k_lambda');
            x_new = obj.x + k*eta;
            
            % save vars
            obj.x = x_new;
            obj.P = P_new;
            
            if inputs.Results.verbosity > 1
                fprintf('x:');
                fprintf('%0.2f ',obj.x);
                fprintf('\n');
            end
            
            % save new measurement
            h_new = circshift(obj.h,1);
            h_new(1) = y;
            obj.h = h_new;
        end
    end
    
end

