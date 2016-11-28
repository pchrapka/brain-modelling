classdef MCMTQRDLSL1
    %MCMTQRDLSL1 Multichannel Multitrial QR-Decomposition-based Least
    %Squares Lattice algorithm
    %   The implementation is as described in Lewis1990
    %   TODO add source
    
    properties (SetAccess = protected)
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
        % number of trials
        ntrials;
        
        % name
        name
    end
    
    properties
        % weighting factor
        lambda;
    end
    
    methods
        function obj = MCMTQRDLSL1(channels, order, trials, lambda)
            %MCMTQRDLSL1 constructor for MQRDLSL1
            %   MCMTQRDLSL1(channels, order, trials, lambda) creates a
            %   MCMTQRDLSL1 object
            %
            %   Input
            %   -----
            %   trials (integer)
            %       number of trials
            %   channels (integer)
            %       number of channels
            %   order (integer)
            %       filter order
            %   lambda (scalar)
            %       exponential weighting factor between 0 and 1
            
            if ~(trials > 1)
                % tell user to use MQRDLSL1, it'll probably be faster and
                % will keep the code simpler here
                error([mfilename ':MCMTQRDLSL1'],...
                    'use MQRDLSL1 for single trial');
            end
            
            obj.ntrials = trials;
            obj.order = order;
            obj.nchannels = channels;
            obj.lambda = lambda;
            
            zeroMat = zeros(obj.order+1, obj.nchannels, obj.nchannels);

            obj.Rf = zeroMat; % \tilde{R} forward squared (e)
            obj.Rb = zeroMat; % \tilde{R} backward squared (r)
            obj.Xf = zeroMat; % \tilde{X} forward squared (e)
            obj.Xb = zeroMat; % \tilde{X} backward squared (r)
            
            obj.berrord = zeros(obj.nchannels, obj.ntrials, obj.order+1);
            obj.gammasqd = zeros(obj.ntrials, obj.ntrials, obj.order+1);
            for j=1:obj.ntrials
                obj.gammasqd(:,:,j) = eye(obj.ntrials);
            end

            zeroMat2 = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat2;
            obj.Kf = zeroMat2;
            
            obj.name = sprintf('MCMTQRDLSL1 T%d C%d P%d lambda=%0.2f',...
                trials, channels, order, lambda);
        end
        
        function obj = update(obj, x, varargin)
            %UPDATE updates reflection coefficients
            %   UPDATE(OBJ,X,...) updates the reflection coefficients using the
            %   measurement X
            %
            %   Input
            %   -----
            %   x (matrix)
            %       new measurements at current iteration, the vector has
            %       the size [channels trials]
            %
            %   Parameters
            %   ----------
            %   verbosity (integer, default = 0)
            %       vebosity level, options: 0 1 2 3
            
            inputs = inputParser();
            params_verbosity = [0 1 2 3];
            addParameter(inputs,'verbosity',0,@(x) any(find(params_verbosity == x)));
            parse(inputs,varargin{:});
            
            use_cholupdate = true;
            
            if ~isequal(size(x), [obj.nchannels obj.ntrials])
                error([mfilename ':update'],...
                    'samples do not match filter size:\n  channels: %d\n  trials: %d',...
                    obj.nchannels, obj.ntrials);
            end
            
            % allocate mem
            zeroMat = zeros(obj.nchannels, obj.ntrials, obj.order+1); 
            ferror = zeroMat;
            berror = zeroMat;
            gammasq = zeros(obj.ntrials, obj.ntrials, obj.order+1,1);
            
            p = 1;
            % ferror is always updated from the previous order, so we don't
            % need to save anything between iterations
            % ferror at order 0 is initialized to the input
            ferror(:,:,p) = x;
            
            % berror turns into the delayed signal at the end
            % berror at order 0 is initialized to the input
            berror(:,:,p) = x;
            
            % gammasq is initialized to 1 for order 0
            gammasq(:,:,p) = eye(obj.ntrials);
            
            % get number of channels
            m = obj.nchannels;
            q = obj.ntrials;
            
            % loop through stages
            for p=2:obj.order+1
                if inputs.Results.verbosity > 1
                    fprintf('order %d\n', p-1);
                end
                
                % gamma
                % FIXME This is probably not that fast
                if use_cholupdate
                    % gammasqd is the cholesky factor
                    gammad = obj.gammasqd(:,:,p-1);
                    if rcond(gammad) <= 2*eps
                        if inputs.Results.verbosity > 0
                            fprintf('bad cond - resetting gamma\n');
                        end
                        gammad = eye(obj.ntrials);
                    end
                    %gammad_inv = inv(gammad);
                else
                    % check the condition number
                    if rcond(obj.gammasqd(:,:,p-1)) <= 4*eps
                        if inputs.Results.verbosity > 0
                            fprintf('bad cond - resetting gamma\n');
                        end
                        gammad = eye(obj.ntrials);
                        %gammad_inv = zeros(obj.ntrials);
                    else
                        [gammad,err] = chol(obj.gammasqd(:,:,p-1));
                        if err > 0
                            % NOTE Often gammasqd may not be PSD and we'll end
                            % up with an error
                            if inputs.Results.verbosity > 0
                                fprintf('not psd - resetting gamma\n');
                            end
                            gammad = eye(obj.ntrials);
                        end
                        %gammad_inv = inv(gammad);
                    end
                end
                
                % forward errors
                yf1 = gammad\(ferror(:,:,p-1)');
                yf2 = gammad\(obj.berrord(:,:,p-1)');
                Yf1 = obj.lambda*squeeze(obj.Rf(p,:,:));
                Yf2 = obj.lambda*squeeze(obj.Xf(p,:,:));
                Yf = [Yf1 Yf2 zeros(m,q)];
                for j=1:q
                    Yf(m+1,:) = [yf1(j,:) yf2(j,:) gammad(j,:)];
                    % NOTE the row to be zeroed is last so I can use the
                    % standard Givens rotation with no modifications
                    if inputs.Results.verbosity > 2
                        display(Yf)
                    end
                    Yf = givens_lsl(Yf,m);
                    if inputs.Results.verbosity > 2
                        display(Yf)
                    end
                    if inputs.Results.verbosity > 1
                        if ~isempty(find(isnan(Yf),1))
                            fprintf('got some nans\n');
                        end
                    end
                    % remove last row
                    Yf(m+1,:) = [];
                end
                
                % extract updated R,X,Beta
                Rf = Yf(:,1:m);
                Xf = Yf(:,m+1:2*m);
                Betaf = Yf(:,2*m+1:end);
                if inputs.Results.verbosity > 2
                    display(Rf)
                    display(Xf)
                    display(Betaf)
                end
                
                % backward errors
                yb1 = gammad\(obj.berrord(:,:,p-1)');
                yb2 = gammad\(ferror(:,:,p-1)');
                Yb1 = obj.lambda*squeeze(obj.Rb(p,:,:));
                Yb2 = obj.lambda*squeeze(obj.Xb(p,:,:));                
                Yb = [Yb1 Yb2 zeros(m,q)];
                for j=1:q
                    Yb(m+1,:) = [yb1(j,:) yb2(j,:) gammad(j,:)];
                    % NOTE the row to be zeroed is last so I can use the
                    % standard Givens rotation with no modifications
                    if inputs.Results.verbosity > 2
                        display(Yb)
                    end
                    Yb = givens_lsl(Yb,m);
                    if inputs.Results.verbosity > 2
                        display(Yb)
                    end
                    if inputs.Results.verbosity > 1
                        if ~isempty(find(isnan(Yb),1))
                            fprintf('got some nans\n');
                        end
                    end
                    % remove last row
                    Yb(m+1,:) = [];
                end
                
                % extract updated R,X,Beta
                Rb = Yb(:,1:m);
                Xb = Yb(:,m+1:2*m);
                Betab = Yb(:,2*m+1:end);
                if inputs.Results.verbosity > 2
                    display(Rb)
                    display(Xb)
                    display(Betab)
                end
                
                % update errors
                ferror(:,:,p) = ferror(:,:,p-1) - Xb'*Betab;
                berror(:,:,p) = obj.berrord(:,:,p-1) - Xf'*Betaf;
                if ~use_cholupdate
                    gammasq(:,:,p) = obj.gammasqd(:,:,p-1) - Betaf'*Betaf;
                else
                    % use cholupdate for stability
                    for j=1:m
                        [gammasq(:,:,p),err] = cholupdate(gammad,Betaf(j,:)','-');
                        if err == 1
                            if inputs.Results.verbosity > 0
                                fprintf('chol update %d\n',j);
                                fprintf('\tfailed\n');
                            end
                            gammasq(:,:,p) = gammad;
                        end
                    end
                end
                if inputs.Results.verbosity > 2
                    fprintf('ferror\n');
                    display(ferror(:,:,p))
                    fprintf('berror\n');
                    display(berror(:,:,p))
                    fprintf('gammasq\n');
                    display(gammasq(:,:,p))
                end
%                 if abs(gammasq(p)) <= eps
%                     fprintf('gammasq is < eps\n');
%                     % NOTE if gammasq becomes zero, the next iteration will
%                     % contain NaNs since the first step is 1/gamma
%                 end
                if inputs.Results.verbosity > 1
                    if isnan(gammasq(p))
                        fprintf('gammasq is nan\n');
                    end
                end
                
                % calculate reflection coefficients
                obj.Kf(p-1,:,:) = Rf\Xf;
                obj.Kb(p-1,:,:) = (Rb\Xb)';
                % NOTE these are singular for the first few iterations
                % because there are not enough samples, so Rb isn't full
                % rank
                
                % save vars
                obj.Rf(p,:,:) = Rf;
                obj.Xf(p,:,:) = Xf;
                
                obj.Rb(p,:,:) = Rb;
                obj.Xb(p,:,:) = Xb;
                
            end
            
            % save current values as delayed versions for next iteration
            obj.berrord = berror;
            obj.gammasqd = gammasq;
            
        end
    end
    
end

