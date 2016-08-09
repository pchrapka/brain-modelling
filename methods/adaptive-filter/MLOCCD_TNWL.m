classdef MLOCCD_TNWL
    %MLOCCD_TNWL Multichannel Lattice Online Cyclic Coordinate Descent Time and Norm Weighted Lasso
    %   Based on Algorithm 3 from 
    %   D. Angelosante, J. A. Bazerque, and G. B. Giannakis, “Online
    %   Adaptive Estimation of Sparse Signals: Where RLS Meets the -Norm,”
    %   IEEE Transactions on Signal Processing, vol. 58, no. 7, pp.
    %   3436–3447, Jul. 2010.
    %
    %   Potential issues
    %   Norm weight is dependent on RLS estimate, not exactly sure if
    %   there's a better way to do this other than have a bunch of
    %   individual RLS filters
    %   

    
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
        
        % norm weight parameters
        a;  % tuning parameter
        lambda_sum; 
        
        % rls filters
        rls_kf;
        rls_kb;
        lsl;
        
        berrord;
        rf;
        rb;
        Rf;
        Rb;
        % reflection coefficients
        Kf;
        Kb;
        
        % name
        name
    end
    
    methods
        function obj = MLOCCD_TNWL(channels,order,varargin)
            %MLOCCD_TNWL
            %   MLOCCD_TNWL(channels,order,...)
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
            %   a (scalar, default = 3)
            %       norm weight tuning parameter, constant > 1
            
            p = inputParser;
            addRequired(p,'channels');
            addRequired(p,'order');
            addParameter(p,'lambda',0.99);
            addParameter(p,'gamma',1.2);
            addParameter(p,'a',3,@(x) x > 1);
            addParameter(p,'mu','',@(x) isempty(x) || x > 0);
            parse(p,channels,order,varargin{:});
            
            obj.order = p.Results.order;
            obj.nchannels = p.Results.channels;
            obj.nregressors = obj.nchannels;
            obj.gamma = p.Results.gamma;
            obj.lambda = p.Results.lambda;
            obj.a = p.Results.a;
            obj.lambda_sum = 1;
            obj.name = sprintf('MLOCCD_TNWL C%d P%d lambda=%0.2f gamma=%0.2f a=%0.2f',...
                obj.nchannels, obj.order, obj.lambda, obj.gamma, obj.a);
            
            zeroMat2 = zeros(obj.order+1,obj.nchannels,obj.nchannels);
            zeroMat3 = zeros(obj.order,obj.nchannels,obj.nchannels);
            
            obj.rf = zeroMat2;
            obj.rb = zeroMat2;
            
            obj.Rf = zeroMat3;
            obj.Rb = zeroMat3;
            for i=1:obj.order
                obj.Rf(i,:,:) = eye(obj.nchannels);
                obj.Rb(i,:,:) = eye(obj.nchannels);
            end
            
            obj.Kf = zeroMat3;
            obj.Kb = zeroMat3;
            
            obj.berrord = zeros(obj.nchannels,obj.order+1);
            
            for i=1:obj.order
                for j=1:obj.nchannels
                    obj.rls_kf{i,j} = RLS(obj.nchannels,'lambda',obj.lambda);
                    obj.rls_kb{i,j} = RLS(obj.nchannels,'lambda',obj.lambda);
                end
            end
            
%             obj.lsl = MQRDLSL1(obj.nchannels, obj.order, obj.lambda);
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
            %   mu (positive scalar, default = see below)
            %       time varying norm weight parameter dependent on sample
            %       size
            %       default = $\frac{\gamma}{\sum_{n=1}^N \lambda^{N-n}}$
            
            inputs = inputParser();
            params_verbosity = [0 1 2 3];
            addParameter(inputs,'verbosity',0,@(x) any(find(params_verbosity == x)));
            addParameter(inputs,'mu','',@(x) isempty(x) || x > 0);
            parse(inputs,varargin{:});
            
            if isempty(inputs.Results.mu)
                mu = obj.gamma/obj.lambda_sum;
                obj.lambda_sum = obj.lambda_sum*obj.lambda + 1;
            else
                mu = inputs.Results.mu;
            end
            
            if ~isequal(size(y), [obj.nchannels 1])
                error([mfilename ':update'],...
                    'samples do not match filter channels: %d %d',...
                    size(y,1), obj.nchannels);
            end
            
            zeroMat = zeros(obj.nchannels,obj.order+1);
            ferror = zeroMat;
            berror = zeroMat;
            
            ferror(:,1) = y;
            berror(:,1) = y;
            
%             obj.lsl.update(y);
            
            % NOTE 
            % RLS Approach
            % - less difference between different a parameters
            % MQRDLSL Approach
            % - sometimes it gets beat by the original MQRDLSL
            % - strange behaviour sometimes
            
            for m=2:obj.order+1
                Rb_old = squeeze(obj.Rb(m-1,:,:));
                Rb_new = obj.lambda*Rb_old + obj.berrord(:,m-1)*obj.berrord(:,m-1)';
                
                Rf_old = squeeze(obj.Rf(m-1,:,:));
                Rf_new = obj.lambda*Rf_old + ferror(:,m-1)*ferror(:,m-1)';
                
                for ch=1:obj.nchannels
                    kf_new = squeeze(obj.Kf(m-1,ch,:));
                    kb_new = squeeze(obj.Kb(m-1,ch,:));
                    
                    % update rls filters
                    % NOTE I'm not entirely sure about this, the explicit
                    % algorithm is not provided in the paper
                    % THOUGHT
                    %   ferror here isn't exactly based on the RLS algo,
                    %   maybe what I need here is the estimate provided by
                    %   MQRDLSL
                    obj.rls_kf{m-1,ch}.update(ferror(ch,m-1));
                    obj.rls_kb{m-1,ch}.update(obj.berrord(ch,m-1));
                    
                    % get rls estimate of kf and kb
                    kf_rls = flip(obj.rls_kf{m-1,ch}.x);
                    kb_rls = flip(obj.rls_kb{m-1,ch}.x);
                    
%                     kf_rls = obj.lsl.Kf(m-1,ch,:);
%                     kb_rls = obj.lsl.Kb(m-1,ch,:);
                    
                    % eq 8
                    rf_new = obj.lambda*squeeze(obj.rf(m,ch,:)) + ferror(ch,m-1)*obj.berrord(:,m-1);
                    rb_new = obj.lambda*squeeze(obj.rb(m,ch,:)) + obj.berrord(ch,m-1)*ferror(:,m-1);
                    
                    for p=1:obj.nregressors
                        idx = true(obj.nregressors,1);
                        idx(p) = false;
                        
                        % eq 18
                        if obj.nregressors == 1
                            rfp = rf_new(p);
                            rbp = rb_new(p);
                        else
                            rfp = rf_new(p) - Rf_new(p,idx)*kf_new(idx);
                            rbp = rb_new(p) - Rb_new(p,idx)*kb_new(idx);
                        end
                        % NOTE I think there's an error in Algorithm 3 in the paper
                        % It says to use obj.x instead of x_new
                        
                        % eq 12
                        weight_kf = obj.norm_weight(mu,kf_rls(p));
                        weight_kb = obj.norm_weight(mu,kb_rls(p));
                        
                        % eq 19
                        kf_new(p) = sign(rfp)/Rf_new(p,p)*max((abs(rfp) - obj.gamma*weight_kf),0);
                        kb_new(p) = sign(rbp)/Rb_new(p,p)*max((abs(rbp) - obj.gamma*weight_kb),0);
                    end
                    
                    % update prediction errors
                    ferror(ch,m) = ferror(ch,m-1) - obj.berrord(:,m-1)'*kf_new;
                    berror(ch,m) = obj.berrord(ch,m-1) - ferror(:,m-1)'*kb_new;
                    
                    % save vars
                    obj.Kf(m-1,ch,:) = kf_new;
                    obj.Kb(m-1,ch,:) = kb_new;
                    obj.rf(m,ch,:) = rf_new;
                    obj.rb(m,ch,:) = rb_new;
                    
                    %fprintf('ch%02d kf:',ch);
                    %fprintf('%0.2f ',obj.kf(ch,:));
                    %fprintf('\n');
                end
                
                % save vars
                obj.Rf(m-1,:,:) = Rf_new;
                obj.Rb(m-1,:,:) = Rb_new;
            end
            
            % save backward error
            obj.berrord = berror;
            
            % % reshape to 3d matrix
            % % FIXME double check this manipulation
            %obj.Kf = reshape(obj.kf,obj.nchannels,obj.nchannels,obj.order);
            %obj.Kf = shiftdim(obj.Kf,2);
            
            %obj.Kb = reshape(obj.kb,obj.nchannels,obj.nchannels,obj.order);
            %obj.Kb = shiftdim(obj.Kb,2);
            
        end
    end
    
    methods(Access = protected)
        function weight = norm_weight(obj,mu,rls_est)
            rls_est = abs(rls_est);
            u1 = (rls_est - mu >= 0);
            u2 = (mu - rls_est >= 0);
            weight = max(obj.a*mu - rls_est,0)/((obj.a-1)*mu).*u1 + u2;
        end
    end
    
end

