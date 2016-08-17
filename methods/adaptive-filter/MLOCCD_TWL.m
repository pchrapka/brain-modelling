classdef MLOCCD_TWL
    %MLOCCD_TWL Multichannel Lattice Online Cyclic Coordinate Descent Time Weighted Lasso
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
        function obj = MLOCCD_TWL(channels,order,varargin)
            %MLOCCD_TWL
            %   MLOCCD_TWL(channels,order,...)
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
            obj.nregressors = obj.nchannels;
            obj.gamma = p.Results.gamma;
            obj.lambda = p.Results.lambda;
            obj.name = sprintf('MLOCCD_TWL C%d P%d lambda=%0.2f gamma=%0.2f',...
                obj.nchannels, obj.order, obj.lambda, obj.gamma);
            
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
            
            zeroMat = zeros(obj.nchannels,obj.order+1);
            ferror = zeroMat;
            berror = zeroMat;
            
            ferror(:,1) = y;
            berror(:,1) = y;
            
            for m=2:obj.order+1
                Rb_old = squeeze(obj.Rb(m-1,:,:));
                Rb_new = obj.lambda*Rb_old + obj.berrord(:,m-1)*obj.berrord(:,m-1)';
                
                Rf_old = squeeze(obj.Rf(m-1,:,:));
                Rf_new = obj.lambda*Rf_old + ferror(:,m-1)*ferror(:,m-1)';
                
                for ch=1:obj.nchannels
                    kf_new = squeeze(obj.Kf(m-1,ch,:));
                    kb_new = squeeze(obj.Kb(m-1,ch,:));
                    
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
                        
                        % eq 19
                        kf_new(p) = sign(rfp)/Rf_new(p,p)*max((abs(rfp) - obj.gamma),0);
                        kb_new(p) = sign(rbp)/Rb_new(p,p)*max((abs(rbp) - obj.gamma),0);
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
    
end

