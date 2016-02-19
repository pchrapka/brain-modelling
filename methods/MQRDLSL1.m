classdef MQRDLSL1 < handle
    %MQRDLSL1 Multichannel QR-Decomposition-based Least Squares Lattice
    %algorithm
    %   The implementation is as described in Lewis1990
    %   TODO add source
    
    properties
        % filter variables
        Rf;     % R forward (e)
        Rb;     % R backward (r)
        Xf;     % X forward (e)
        Xb;     % X backward (r)
        
        gammasqd;   % delayed gamma^2
        berrord;    % delayed backward prediction error
        
        % reflection coefficients
        Kb;
        Kf;
        
        % filter order
        order;
        
        % number of channels
        nchannels;
        
        % weighting factor
        lambda;
    end
    
    methods
        function obj = MQRDLSL1(channels, order, lambda)
            %MQRDLSL1 constructor for MQRDLSL1
            %   MQRDLSL1(ORDER, LAMBDA) creates a MQRDLSL1 object
            %
            %   channels (integer)
            %       number of channels
            %   order (integer)
            %       filter order
            %   lambda (scalar)
            %       exponential weighting factor between 0 and 1
            
            obj.order = order;
            obj.nchannels = channels;
            obj.lambda = lambda;
            
            zeroMat = zeros(obj.order+1, obj.nchannels, obj.nchannels);

            obj.Rf = zeroMat; % \tilde{R} forward squared (e)
            obj.Rb = zeroMat; % \tilde{R} backward squared (r)
            obj.Xf = zeroMat; % \tilde{X} forward squared (e)
            obj.Xb = zeroMat; % \tilde{X} backward squared (r)
            
            obj.berrord = zeros(obj.nchannels, obj.order+1);
            obj.gammasqd = ones(obj.order+1, 1);

            obj.Kb = zeroMat;
            obj.Kf = zeroMat;
        end
        
        function obj = update(obj, x)
            %UPDATE updates reflection coefficients
            %   UPDATE(OBJ,X) updates the reflection coefficients using the
            %   measurement X
            %
            %   x (vector)
            %       new measurement
            
            debug_prints = false;
            
            x = x(:);
            if ~isequal(size(x), [obj.nchannels 1])
                error('bad input size: %d %d', size(x,1), size(x,2));
            end
            
            % allocate mem
            zeroMat = zeros(obj.nchannels,obj.order+1); 
            ferror = zeroMat;
            berror = zeroMat;
            gammasq = zeros(obj.order+1,1);
            
            p = 1;
            % ferror is always updated from the previous order, so we don't
            % need to save anything between iterations
            % ferror at order 0 is initialized to the input
            ferror(:,p) = x;
            
            % berror turns into the delayed signal at the end
            % berror at order 0 is initialized to the input
            berror(:,p) = x;
            
            % gammasq is initialized to 1 for order 0
            gammasq(p) = 1;
            
            % get number of channels
            m = obj.nchannels;
            
            % loop through stages
            for p=2:obj.order+1
                if debug_prints
                    fprintf('order %d\n', p-1);
                end
                
                % gamma
                gammad = sqrt(obj.gammasqd(p-1));
                if gammad < eps
                    gammad_inv = 0;
                else
                    gammad_inv = 1/gammad;
                end
                
                % forward errors
                yf1 = gammad_inv*ferror(:,p-1);
                yf2 = gammad_inv*obj.berrord(:,p-1);
                Yf1 = obj.lambda*squeeze(obj.Rf(p,:,:));
                Yf2 = obj.lambda*squeeze(obj.Xf(p,:,:));
                Yf = [...
                    Yf1      Yf2      zeros(m,1);...
                    yf1'     yf2'     gammad;...
                    ];
                % NOTE the row to be zeroed is last so I can use the
                % standard Givens rotation with no modifications
                if debug_prints
                    display(Yf)
                end
                Yf = givens_lsl(Yf,m);
                if debug_prints
                    display(Yf)
                end
                if ~isempty(find(isnan(Yf),1))
                    fprintf('got some nans\n');
                end
                % remove last row
                Yf(end,:) = [];
                
                % extract updated R,X,beta
                Rf = Yf(:,1:m);
                Xf = Yf(:,m+1:2*m);
                betaf = Yf(:,end);
                if debug_prints
                    display(Rf)
                    display(Xf)
                    display(betaf)
                end
                
                % backward errors
                yb1 = gammad_inv*obj.berrord(:,p-1);
                yb2 = gammad_inv*ferror(:,p-1);
                Yb1 = obj.lambda*squeeze(obj.Rb(p,:,:));
                Yb2 = obj.lambda*squeeze(obj.Xb(p,:,:));
                Yb = [...
                    Yb1      Yb2      zeros(m,1);...
                    yb1'     yb2'     gammad;...                    
                    ];
                % NOTE the row to be zeroed is last so I can use the
                % standard Givens rotation with no modifications
                if debug_prints
                    display(Yb)
                end
                Yb = givens_lsl(Yb,m);
                if debug_prints
                    display(Yb)
                end
                if ~isempty(find(isnan(Yb),1))
                    fprintf('got some nans\n');
                end
                % remove last row
                Yb(end,:) = [];
                
                % extract updated R,X,beta
                Rb = Yb(:,1:m);
                Xb = Yb(:,m+1:2*m);
                betab = Yb(:,end);
                if debug_prints
                    display(Rb)
                    display(Xb)
                    display(betab)
                end
                
                % update errors
                % TODO Check if Dbsq needs to be inverted
                ferror(:,p) = ferror(:,p-1) - Xb'*betab;
                berror(:,p) = obj.berrord(:,p-1) - Xf'*betaf;
                gammasq(p) = obj.gammasqd(p-1) - betaf'*betaf;
                if debug_prints
                    fprintf('ferror\n');
                    display(ferror(:,p))
                    fprintf('berror\n');
                    display(berror(:,p))
                    fprintf('gammasq\n');
                    display(gammasq(p))
                end
                if abs(gammasq(p)) <= eps
                    fprintf('gammasq is < eps\n');
                    % NOTE if gammasq becomes zero, the next iteration will
                    % contain NaNs since the first step is 1/gamma
                end
                if isnan(gammasq(p))
                    fprintf('gammasq is nan\n');
                end
                
                % calculate reflection coefficients
                obj.Kf(p,:,:) = Rf\Xf;
                obj.Kb(p,:,:) = (Rb\Xb)';
                % NOTE these are singular for the first few iterations
                % because there are not enough samples, so Rb isn't full
                % rank
                
                % save vars
                obj.Rf(p,:,:) = Rf;
                obj.Xf(p,:,:) = Xf;
                
                obj.Rb(p,:,:) = Rb;
                obj.Xb(p,:,:) = Xb;
                
            end
            
            obj.Kf(1,:,:) = [];
            obj.Kb(1,:,:) = [];
            
            % save current values as delayed versions for next iteration
            obj.berrord = berror;
            obj.gammasqd = gammasq;
            
        end
    end
    
end

