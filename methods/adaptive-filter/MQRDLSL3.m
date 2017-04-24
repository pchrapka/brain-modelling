classdef MQRDLSL3
    %MQRDLSL3 Multichannel QR-Decomposition-based Least Squares Lattice
    %algorithm
    %   The implementation is as described in Yang1990
    %   TODO add source
    
    properties (SetAccess = protected)
        % filter variables
        Rf;     % R forward (e)
        Rfinvt;
        Rb;     % R backward (r)
        Rbinvt;
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
        
        % name
        name
    end
    
    properties
        % weighting factor
        lambda;
    end
    
    methods
        function obj = MQRDLSL3(channels, order, lambda)
            %MQRDLSL3 constructor for MQRDLSL3
            %   MQRDLSL3(ORDER, LAMBDA) creates a MQRDLSL3 object
            %
            %   channels (integer)
            %       number of channels
            %   order (integer)
            %       filter order
            %   lambda (scalar)
            %       exponential weighting factor between 0 and 1
            
            p = inputParser;
            addRequired(p,'channels', @(x) isnumeric(x) && isscalar(x));
            addRequired(p,'order', @(x) isnumeric(x) && isscalar(x));
            addRequired(p,'lambda',@(x) isnumeric(x) && isscalar(x));
            parse(p,channels,order,lambda);
            
            obj.order = order;
            obj.nchannels = channels;
            obj.lambda = lambda;
            
            zeroMat = zeros(obj.order+1, obj.nchannels, obj.nchannels);

            delta = 0.01;
            C = delta*eye(obj.nchannels);
            R = chol(C);
            for i=1:obj.order+1
                obj.Rf(i,:,:) = R;
                obj.Rfinvt(i,:,:) = inv(R');
                obj.Rb(i,:,:) = R;
                obj.Rbinvt(i,:,:) = inv(R');
            end
            obj.Xf = zeroMat; % \tilde{X} forward squared (e)
            obj.Xb = zeroMat; % \tilde{X} backward squared (r)
            
            obj.berrord = zeros(obj.nchannels, obj.order+1);
            obj.gammasqd = ones(obj.order+1, 1);

            zeroMat2 = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat2;
            obj.Kf = zeroMat2;
            
            obj.name = sprintf('MQRDLSL3 C%d P%d lambda=%0.2f',...
                channels, order, lambda);
        end
        
        function obj = normalize(obj, nsamples)
            %NORMALIZE normalize the covariance matrices
            %   NORMALIZE(obj, nsamples) normalize the covariance matrices
            
            %weight = (1-obj.lambda)/(1-obj.lambda^nsamples);
        end
        
        function obj = update(obj, x, varargin)
            %UPDATE updates reflection coefficients
            %   UPDATE(OBJ,X) updates the reflection coefficients using the
            %   measurement X
            %
            %   Input
            %   -----
            %   x (vector)
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
            
            if ~isequal(size(x), [obj.nchannels 1])
                error([mfilename ':update'],...
                    'samples do not match filter channels: %d %d',...
                    size(x,1), obj.nchannels);
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
                if inputs.Results.verbosity > 1
                    fprintf('order %d\n', p-1);
                end
                
                % gamma
                gammad = sqrt(obj.gammasqd(p-1));
                gammad_inv = 1/gammad;
                
                % forward errors
                yf1 = gammad_inv*ferror(:,p-1);
                yf2 = gammad_inv*obj.berrord(:,p-1);
                Yf1 = sqrt(obj.lambda)*squeeze(obj.Rf(p,:,:));
                Yf2 = sqrt(obj.lambda)*squeeze(obj.Xf(p,:,:));
                Yf3 = squeeze(obj.Rfinvt(p,:,:))/sqrt(obj.lambda);
                Yf = [...
                    Yf1      Yf2      Yf3           zeros(m,1);...
                    yf1'     yf2'     zeros(1,m)    gammad;...
                    ];
                % NOTE the row to be zeroed is last so I can use the
                % standard Givens rotation with no modifications
                Yf = givens_lsl(Yf,m);
                
                % extract updated R,X,beta
                Rf = Yf(1:m,1:m);
                Xf = Yf(1:m,m+1:2*m);
                berrortilde = Yf(m+1,m+1:2*m)'; %order p
                Rfinvt = Yf(1:m,2*m+1:3*m);
                gf = Yf(m+1,2*m+1:3*m)';
                %betaf = Yf(1:m,end);
                gammatilde = Yf(m+1,end); % order p
                
                % backward errors
                yb1 = gammad_inv*obj.berrord(:,p-1);
                yb2 = gammad_inv*ferror(:,p-1);
                Yb1 = sqrt(obj.lambda)*squeeze(obj.Rb(p,:,:));
                Yb2 = sqrt(obj.lambda)*squeeze(obj.Xb(p,:,:));
                Yb3 = squeeze(obj.Rbinvt(p,:,:))/sqrt(obj.lambda);
                Yb = [...
                    Yb1      Yb2      Yb3           zeros(m,1);...
                    yb1'     yb2'     zeros(1,m)    gammad;...
                    ];
                % NOTE the row to be zeroed is last so I can use the
                % standard Givens rotation with no modifications
                Yb = givens_lsl(Yb,m);
                
                % extract updated R,X,beta
                Rb = Yb(1:m,1:m);
                Xb = Yb(1:m,m+1:2*m);
                ferrortilde = Yb(m+1,m+1:2*m)'; %order p
                Rbinvt = Yb(1:m,2*m+1:3*m);
                gb = Yb(m+1,2*m+1:3*m)';
                %betab = Yb(1:m,end);
                gammadtilde = Yb(m+1,end); % order p
                
                % update errors
                ferror(:,p) = gammadtilde*ferrortilde;
                berror(:,p) = gammatilde*berrortilde;
                gammasq(p) = gammatilde^2;
                
                % calculate reflection coefficients
                obj.Kf(p-1,:,:) = squeeze(obj.Kf(p-1,:,:)) - gf*berrortilde';
                obj.Kb(p-1,:,:) = squeeze(obj.Kb(p-1,:,:)) - gb*ferrortilde';
                
                % save vars
                obj.Rf(p,:,:) = Rf;
                obj.Rfinvt(p,:,:) = Rfinvt;
                obj.Xf(p,:,:) = Xf;
                
                obj.Rb(p,:,:) = Rb;
                obj.Rbinvt(p,:,:) = Rbinvt;
                obj.Xb(p,:,:) = Xb;
                
            end
            
            % save current values as delayed versions for next iteration
            obj.berrord = berror;
            obj.gammasqd = gammasq;
            
        end
    end
    
end

