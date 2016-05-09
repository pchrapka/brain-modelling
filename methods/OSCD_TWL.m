classdef OSCD_TWL < handle
    %OSCD_TWL Summary of this class goes here
    %   Detailed explanation goes here
    
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
        
        % number of channels
        nchannels;
        
        % name
        name
    end
    
    methods
        function obj = OSCD_TWL(order,lambda,beta)
            obj.order = order;
            obj.nchannels = 1;
            obj.lambda = lambda;
            obj.beta = beta;
            obj.name = sprintf('OSCD_TWL C%d P%d beta=%0.2f lambda=%0.2f',...
                obj.nchannels, order, beta, lambda);
            
            zeroVec = zeros(order,1);
            obj.h = zeroVec;
            obj.r = zeroVec;
            obj.x = zeroVec;
            obj.R = eye(order);
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
            
            % eq 8
            r_new = obj.beta*obj.r + y*obj.h;
            R_new = obj.beta*obj.R + obj.h*obj.h';
            
            % calculate directional derivatires
            splus = 1*(obj.x >= 0);
            splus(splus == 0) = -1;
            sminus = 1*(obj.x <= 0);
            sminus(sminus == 0) = -1;
            % eq 20
            dplus = R_new*obj.x - r_new + obj.lambda*splus;
            % eq 21
            dminus = r_new - R_new*obj.x + obj.lambda*sminus;
            
            % find smallest derivative
            [dmin,pstar_row] = min([dplus dminus]);
            [~,pstar_col] = min(dmin);
            pstar_idx = pstar_row(pstar_col);
            
            % update most negative directional derivative
            idx = true(obj.order,1);
            idx(pstar_idx) = false;
            
            % eq 18
            rp = r_new(pstar_idx) - sum(R_new(pstar_idx,idx).*obj.x(idx)');
            % eq 19
            x_new = obj.x;
            x_new(pstar_idx) = sign(rp)/R_new(pstar_idx,pstar_idx)*max((abs(rp) - obj.lambda),0);
            
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

