classdef MCMTLOCCD_TWL2
    %MCMTLOCCD_TWL2 Multichannel Lattice Online Cyclic Coordinate Descent Time Weighted Lasso
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
        % number of trials
        ntrials;
        
        % filter order
        order;
        % regularization parameter
        gamma;
        % forgetting factor
        lambda;
        
        berrord;
        ferror;
        Rbf;
        Rfb;
        Rf;
        Rb;
        % reflection coefficients
        Kf;
        Kb;
        
        % name
        name
    end
    
    methods
        function obj = MCMTLOCCD_TWL2(channels,order,trials,varargin)
            %MCMTLOCCD_TWL2
            %   MCMTLOCCD_TWL2(channels,order,...)
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
            addRequired(p,'trials',@(x) x > 1);
            addParameter(p,'lambda',0.99);
            addParameter(p,'gamma',1.2);
            parse(p,channels,order,trials,varargin{:});
            
            obj.order = p.Results.order;
            obj.nchannels = p.Results.channels;
            obj.ntrials = p.Results.trials;
            obj.nregressors = obj.nchannels;
            obj.gamma = p.Results.gamma;
            obj.lambda = p.Results.lambda;
            obj.name = sprintf('MCMTLOCCD_TWL2 T%d C%d P%d lambda=%0.2f gamma=%0.2f',...
                obj.ntrials, obj.nchannels, obj.order, obj.lambda, obj.gamma);
            
            delta = 0.01;
            C = delta*eye(obj.nchannels);
            R = chol(C);
            for i=1:obj.order+1
                obj.Rf(i,:,:) = R;
                obj.Rfb(i,:,:) = R;
                obj.Rb(i,:,:) = R;
                obj.Rbf(i,:,:) = R;
            end
            
            zeroMat3 = zeros(obj.order,obj.nchannels,obj.nchannels);
            obj.Kf = zeroMat3;
            obj.Kb = zeroMat3;
            
            obj.berrord = zeros(obj.nchannels,obj.ntrials,obj.order+1);
            obj.ferror = zeros(obj.nchannels,obj.ntrials,obj.order+1);
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
            
            if ~isequal(size(y), [obj.nchannels obj.ntrials])
                error([mfilename ':update'],...
                    'samples do not match filter size:\n  channels: %d\n  trials: %d',...
                    obj.nchannels, obj.ntrials);
            end
            
            zeroMat = zeros(obj.nchannels, obj.ntrials, obj.order+1);
            ferror = zeroMat;
            berror = zeroMat;
            
            ferror(:,:,1) = y;
            berror(:,:,1) = y;
            
            for m=2:obj.order+1
                Rb_new = obj.lambda*squeeze(obj.Rb(m-1,:,:)) + obj.berrord(:,:,m-1)*obj.berrord(:,:,m-1)';
                Rf_new = obj.lambda*squeeze(obj.Rf(m-1,:,:)) + ferror(:,:,m-1)*ferror(:,:,m-1)';
                
                Rbf_new = obj.lambda*squeeze(obj.Rbf(m-1,:,:)) + obj.berrord(:,:,m-1)*ferror(:,:,m-1)';
                Rfb_new = obj.lambda*squeeze(obj.Rfb(m-1,:,:)) + ferror(:,:,m-1)*obj.berrord(:,:,m-1)';
                
                parfor ch=1:obj.nchannels
                    kf = squeeze(obj.Kf(m-1,:,ch))';
                    kb = squeeze(obj.Kb(m-1,:,ch))';
                    
                    kf_new = lasso_rls_update(kf, Rf_new, Rfb_new(:,ch), obj.gamma);
                    kb_new = lasso_rls_update(kb, Rb_new, Rbf_new(:,ch), obj.gamma);
                    
                    % save vars
                    obj.Kf(m-1,:,ch) = kf_new;
                    obj.Kb(m-1,:,ch) = kb_new;
                end
                
                % update prediction errors
                ferror(:,:,m) = ferror(:,:,m-1) - squeeze(obj.Kb(m-1,:,:))'*obj.berrord(:,:,m-1);
                berror(:,:,m) = obj.berrord(:,:,m-1) - squeeze(obj.Kf(m-1,:,:))'*ferror(:,:,m-1);
                
                % save vars
                obj.Rbf(m-1,:,:) = Rbf_new;
                obj.Rfb(m-1,:,:) = Rfb_new;
                obj.Rf(m-1,:,:) = Rf_new;
                obj.Rb(m-1,:,:) = Rb_new;
            end
            
            % save backward error
            obj.berrord = berror;
            % save forward error
            obj.ferror = ferror;
            
        end
    end
    
end

