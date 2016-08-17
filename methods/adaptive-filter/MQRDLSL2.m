classdef MQRDLSL2
    %MQRDLSL2 Multichannel QR-Decomposition-based Least Squares Lattice
    %algorithm
    %   The implementation is as described in Lewis1990
    %   TODO add source
    
    properties (SetAccess = protected)
        % filter variables
        dfsq;       % squared diagonal of D forward (e)
        dbsq;       % squared diagonal of D backward squared (r)
        Rtildef;    % \tilde{R} forward (e)
        Rtildeb;    % \tilde{R} backward (r)
        Xtildef;    % \tilde{X} forward (e)
        Xtildeb;    % \tilde{X} backward (r)
        
        gammasqd;   % delayed gamma
        berrord;    % delayed backward prediction error
        ferror;     % forward prediction error

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
        function obj = MQRDLSL2(channels, order, lambda)
            %MQRDLSL2 constructor for MQRDLSL2
            %   MQRDLSL2(ORDER, LAMBDA) creates a MQRDLSL2 object
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
            zeroMat2 = zeros(obj.order+1, obj.nchannels);
            obj.dfsq = zeroMat2; % D forward squared (e)
            obj.dbsq = zeroMat2; % D backward squared (r)
            obj.Rtildef = zeroMat; % \tilde{R} forward squared (e)
            obj.Rtildeb = zeroMat; % \tilde{R} backward squared (r)
            obj.Xtildef = zeroMat; % \tilde{X} forward squared (e)
            obj.Xtildeb = zeroMat; % \tilde{X} backward squared (r)
            
            % init the diagonals of D to 1's
            onesMat = ones(obj.nchannels, obj.order+1);
            obj.dfsq = onesMat;
            obj.dbsq = onesMat;
            
            obj.berrord = zeros(obj.nchannels, obj.order+1);
            obj.ferror = zeros(obj.nchannels, obj.order+1);
            obj.gammasqd = ones(obj.order+1, 1);

            zeroMat3 = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat3;
            obj.Kf = zeroMat3;
            
            obj.name = sprintf('MQRDLSL2 C%d P%d lambda=%0.2f',...
                channels, order, lambda);
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
            
            alpha = 100;
            
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
                
                % forward errors
                df = [...
                    obj.gammasqd(p-1);...
                    obj.lambda^(-2)*obj.dfsq(:,p)...
                    ];
                Yf = [...
                    ferror(:,p-1)' obj.berrord(:,p-1)' obj.gammasqd(p-1);...
                    squeeze(obj.Rtildef(p,:,:)) squeeze(obj.Xtildef(p,:,:)) zeros(m,1);...
                    ];
                if inputs.Results.verbosity > 2
                    display(df)
                    display(Yf)
                end
                if ~isequal(size(Yf),[m+1,2*m+1])
                    error('check size of Yf');
                end
                [Yf,df] = givens_fast_lsl(Yf,df,m);
                if inputs.Results.verbosity > 2
                    display(df)
                    display(Yf)
                end
                if inputs.Results.verbosity > 1
                    if ~isempty(find(isnan(Yf),1))
                        warning('got some nans\n');
                    end
                end
                
                % extract updated R,X,beta
                Rf = Yf(2:end,1:m);
                Xf = Yf(2:end,m+1:2*m);
                betaf = Yf(2:end,end);
                dfsq = df(2:end);
                if inputs.Results.verbosity > 2
                    display(Rf)
                    display(Xf)
                    display(betaf)
                    display(dfsq)
                end
                if inputs.Results.verbosity > 1
                    if ~isempty(find(dfsq == 0,1))
                        warning('dfsq is zero\n');
                    end
                end
                
                % check if we need to rescale
                if ~isempty(find(dfsq > alpha^2,1))
                    % rescale
                    Rf = Rf/alpha;
                    Xf = Xf/alpha;
                    betaf = betaf/alpha;
                    dfsq = dfsq/alpha^2;
                end
                
                % backward errors
                db = [...
                    obj.gammasqd(p-1);...
                    obj.lambda^(-2)*obj.dbsq(:,p)...
                    ];
                Yb = [...
                    obj.berrord(:,p-1)' ferror(:,p-1)' obj.gammasqd(p-1);...
                    squeeze(obj.Rtildeb(p,:,:)) squeeze(obj.Xtildeb(p,:,:)) zeros(m,1);...
                    ];
                if inputs.Results.verbosity > 2
                    display(db)
                    display(Yb)
                end
                if inputs.Results.verbosity > 1
                    if ~isequal(size(Yb),[m+1, 2*m+1])
                        error('check size of Yb');
                    end
                end
                [Yb,db] = givens_fast_lsl(Yb,db,m);
                if inputs.Results.verbosity > 2
                    display(db)
                    display(Yb)
                end
                if inputs.Results.verbosity > 1
                    if ~isempty(find(isnan(Yb),1))
                        warning('got some nans\n');
                    end
                end
                
                % extract updated R,X,beta
                Rb = Yb(2:end,1:m);
                Xb = Yb(2:end,m+1:2*m);
                betab = Yb(2:end,end);
                dbsq = db(2:end);
                if inputs.Results.verbosity > 2
                    display(Rb)
                    display(Xb)
                    display(betab)
                    display(dbsq)
                end
                if inputs.Results.verbosity > 1
                    if ~isempty(find(dbsq == 0,1))
                        warning('dbsq is zero\n');
                    end
                end
                
                % check if we need to rescale
                if ~isempty(find(dbsq > alpha^2,1))
                    % rescale
                    Rb = Rb/alpha;
                    Xb = Xb/alpha;
                    betab = betab/alpha;
                    dbsq = dbsq/alpha^2;
                end
                
                % update errors
                % TODO Check if Dbsq needs to be inverted
                Dbsq_inv = diag(1./dbsq);
                Dfsq_inv = diag(1./dfsq);
                ferror(:,p) = ferror(:,p-1) - Xb'*Dbsq_inv*betab;
                berror(:,p) = obj.berrord(:,p-1) - Xf'*Dfsq_inv*betaf;
                gammasq(p) = obj.gammasqd(p-1) - betaf'*Dfsq_inv*betaf;
                if inputs.Results.verbosity > 2
                    fprintf('ferror\n');
                    display(ferror(:,p))
                    fprintf('berror\n');
                    display(berror(:,p))
                    fprintf('gammasq\n');
                    display(gammasq(p))
                end
                if abs(gammasq(p)) <= eps
                    warning('gammasq is < eps, resetting gammasq\n');
                    % NOTE if gammasq becomes zero that propagates to the
                    % diagonal matrix D that is then supplied to the fast
                    % givens rotation, which assumes that it's positive
                    % I think
                    gammasq(p) = 1;
                end
                if inputs.Results.verbosity > 1
                    if isnan(gammasq(p))
                        warning('gammasq is nan\n');
                    end
                end
                
                % calculate reflection coefficients
                obj.Kf(p-1,:,:) = Rf\Xf;
                obj.Kb(p-1,:,:) = (Rb\Xb)';
                % NOTE these are singular for the first few iterations
                % because there are not enough samples, so Rb isn't full
                % rank
                
                % save vars
                obj.Rtildef(p,:,:) = Rf;
                obj.Xtildef(p,:,:) = Xf;
                obj.dfsq(:,p) = dfsq;
                
                obj.Rtildeb(p,:,:) = Rb;
                obj.Xtildeb(p,:,:) = Xb;
                obj.dbsq(:,p) = dbsq;
                
            end
            
            % save current values as delayed versions for next iteration
            obj.berrord = berror;
            obj.gammasqd = gammasq;
            obj.ferror = ferror;
            
        end
    end
    
end

