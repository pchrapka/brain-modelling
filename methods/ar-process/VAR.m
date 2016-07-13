classdef VAR < VARProcess
    %VAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K; % process dimension
        P; % model order
        
        A; % coefficients
    end
    
    properties(SetAccess = private)
        init = false;
    end
    
    methods
        function obj = VAR(K,order)
            %VAR constructor
            %   VAR(K,p) creates a VAR object with order p and dimension K
            %
            %   Input
            %   -----
            %   K (integer)
            %       process dimension
            %   order (integer)
            %       model order
            
            obj.K = K;
            obj.P = order;
            obj.A = zeros(K,K,order);
        end
            
        
        function coefs_set(obj,A)
            %COEFS_SET sets coefficients of VAR process
            %   COEFS_SET(OBJ, A)
            %
            %   Input
            %   -----
            %   A (matrix)
            %       VAR coefficients of size [K K P]
            
            if isequal(size(A),size(obj.A))
                obj.A = A;
                obj.init = true;
            else
                disp(size(A))
                error([mfilename ':ParamError'],...
                    'bad size, should be [%d %d %d]',...
                    obj.K, obj.K, obj.P);
            end
        end
        
        function coefs_gen(obj)
            %COEFS_GEN generates coefficients of VAR process
            %   COEFS_GEN(OBJ)
            
            method = 'stable';
            switch method
                case 'stable'
                    % Source: http://www.kris-nimark.net/pdf/Handout_S1.pdf
                    
                    % NOTE We assume that A_0 is all ones
                    % Don't know if I should include that in the
                    % coefficients
                    
                    %lambda = 2.5;
                    lambda = 4;
                    for i=1:obj.P
                        obj.A(:,:,i) = (lambda^(-i))*rand(obj.K,obj.K) ...
                            - ((2*lambda)^(-i))*ones(obj.K,obj.K);
                    end
                    
                    obj.init = true;
                    
                otherwise
                    error(mfilename,...
                        'unknown method');
                    
            end
        end
        
        function coefs_gen_sparse(obj, varargin)
            %COEFS_GEN_SPARSE generates coefficients of VAR process
            %   COEFS_GEN_SPARSE(OBJ, sparseness) generates coefficients of
            %   VAR process. this method has a better chance of finding a
            %   stable system with larger eigenvalues.
            %
            %   Parameters
            %   ----------
            %   mode (string, default = probability)
            %       method to select number of coefficients: 'probability'
            %       and 'exact'
            %       probability - sets the probability of a coefficient
            %       being nonzero, requires probability parameter
            %       exact - sets the exact number of coefficients to be
            %       nonzero, requires ncoefs parameter
            %   probability
            %       probability of a coefficient being nonzero, required
            %       when mode = 'probability'
            %   ncoefs (integer)
            %       number of coefficients to be nonzero, required when
            %       mode = 'exact'
            %
            %   stable (logical, default = false)
            %       generates a stable process
            %   verbose (integer, default = 0)
            %       toggles verbosity of function
            
            p = inputParser;
            params_mode = {'probability','exact'};
            addParameter(p,'mode','probability',@(x) any(validatestring(x,params_mode)));
            addParameter(p,'probability',0.1,@isnumeric);
            addParameter(p,'ncoefs',0,@isnumeric);
            addParameter(p,'stable',false,@islogical);
            addParameter(p,'verbose',0,@isnumeric);
            parse(p,varargin{:});
            
            % reset coefs
            obj.A = zeros(obj.K,obj.K,obj.P);
            
            ncoefs = numel(obj.A);
            switch p.Results.mode
                case 'probability'
                    % randomly select coefficient indices
                    idx = rand(ncoefs,1) < p.Results.probability;
                case 'exact'
                    % randomly select coefficient indices
                    num_idx = randsample(1:ncoefs,p.Results.ncoefs);
                    idx = false(ncoefs,1);
                    idx(num_idx) = true;
            end
            
            % interval for uniform distribution
            a = -1;
            b = 1;
            
            if p.Results.stable
                % randomly assign coefficient values one order at a time
                % this makes it a bit easire to get something stable for
                % higher orders
                idx_hier = reshape(idx,obj.K,obj.K,obj.P);
                for i=1:obj.P
                    if p.Results.verbose > 0
                        fprintf('working on order %d\n',i);
                    end
                    
                    stable = false;
                    while ~stable
                        % get new coefs for current order
                        coefs_rand = unifrnd(a,b,obj.K,obj.K);
                        coefs_rand(~idx_hier(:,:,i)) = 0;
                        
                        % select coefs according to random index
                        obj.A(:,:,i) = coefs_rand;
                        
                        % set up a new object of order i
                        s = VAR(obj.K, i);
                        s.coefs_set(obj.A(:,:,1:i));
                        
                        % check stability
                        stable = s.coefs_stable(false);
                    end
                    
                    if p.Results.verbose > 0
                        fprintf('got order %d\n',i);
                    end
                end
            else
                % randomly assign coefficient values from uniform distribution
                nidx = sum(idx);
                obj.A(idx) = a + (b-a).*rand(nidx,1);
            end
            
            obj.init = true;
            
        end
        
        function stable = coefs_stable(obj,verbose)
            %COEFS_STABLE checks VAR coefficients for stability
            %   stable = COEFS_STABLE([verbose]) checks VAR coefficients for stability
            %
            %   Input
            %   -----
            %   verbose (boolean, optional)
            %       toggles verbosity of function, default = false
            %
            %   Output
            %   ------
            %   stable (boolean)
            %       true if stable, false otherwise
            %
            %   References
            %   [1] J. D. Hamilton, Time series analysis, vol. 2. Princeton
            %   university press Princeton, 1994.
            %   	Equation (10.1.10)
            %   [2] H. Lütkepohl, New Introduction to Multiple Time Series
            %   Analysis. Springer Berlin Heidelberg, 2005.
            %       Equation (2.1.9)
            
            
            stable = false;
            if nargin < 2
                verbose = false;
            end
            
            if obj.init
                % Get F matrix
                F = obj.coefs_getF();
                
                % Get eigenvalues
                lambda = eig(F);
                %disp(lambda);
                %disp(abs(lambda));
                
                % Check eigenvalues
                if max(abs(lambda)) >= 1
                    if verbose
                        fprintf('unstable VAR\n');
                        disp(abs(lambda));
                    end
                    stable = false;
                else
                    if verbose
                        fprintf('stable VAR\n');
                        disp(abs(lambda));
                    end
                    stable = true;
                end                
            else
                error('no coefficients set');
            end
            
        end
        
        function F = coefs_getF(obj)
            %COEFS_GETF builds matrix F
            %   COEFS_GETF(OBJ) builds matrix F as defined by Hamilton
            %   (10.1.10)
            %
            %   Output
            %   ------
            %   F (matrix)
            %       coefficient matrix of size [K*P K*P]
            %
            %   References
            %   [1] J. D. Hamilton, Time series analysis, vol. 2. Princeton
            %   university press Princeton, 1994.
            
            % Collect coefs
            F1 = [];
            for p=1:obj.P
                F1 = horzcat(F1, obj.A(:,:,p));
            end
            
            version = 2;
            switch version
                case 1
                    % Source: http://www.kris-nimark.net/pdf/Handout_S1.pdf
                    % Nice way of using sparse matrices
                    
                    % F - [Hamilton, Time Series Analysis, 10.1.10]
                    F2 = cell(1,obj.P-1);
                    [F2{:}] = deal(sparse(eye(obj.K)));
                    F2 = blkdiag(F2{:});
                    F2 = full(F2);
                    F3 = zeros(obj.K*(obj.P-1),obj.K);
                    F = [F1; F2, F3];
                    
                case 2
                    
                    F2 = eye(obj.K*(obj.P-1));
                    F3 = zeros(obj.K*(obj.P-1),obj.K);
                    F = [F1; F2 F3];
                    
            end
            
            % Sanity check
            if ~isequal(size(F),[obj.K*obj.P obj.K*obj.P])
                error('F has a bad size');
            end
        end
        
        function [Y,Y_norm, noise] = simulate(obj, nsamples, varargin)
            %SIMULATE simulate VAR process
            %   [Y,Y_norm,noise] = SIMULATE(obj, nsamples, ...)
            %
            %   Input
            %   -----
            %   nsamples (integer)
            %       number of samples
            %
            %   Parameters
            %   ----------
            %   mu (vector, optional)
            %       mean of VAR process, default is zero
            %   sigma (scalar, default = 0.1)
            %       variance of VAR process
            %
            %   Output
            %   ------
            %   Y (matrix)
            %       simulated VAR process [channels, samples]
            %   Y_norm (matrix)
            %       simulated VAR process, with each channel normalized to
            %       unit variance [channels, samples]
            %   noise (matrix)
            %       driving white noise, [channels, samples]
            %
            % Source: http://www.kris-nimark.net/pdf/Handout_S1.pdf
            
            if ~obj.init
                error('no coefficients set');
            end
            
            inputs = inputParser;
            addParameter(inputs,'mu',zeros(obj.K,1),@isnumeric);
            addParameter(inputs,'sigma',0.1,@isnumeric);
            parse(inputs,varargin{:});
            
            Sigma = inputs.Results.sigma*eye(obj.K);
            
            % Generate initial conditions Y^{-p+1} ... Y^{0}
            Ylag = zeros(obj.K,obj.P);
            for p=1:obj.P
                Ylag(:,p) = mvnrnd(zeros(obj.K,1), Sigma)';
            end
            
            % Generate the process
            noise = mvnrnd(zeros(obj.K,1), Sigma, nsamples)';
            Y = zeros(obj.K,nsamples);
            Y(:,1:obj.P) = Ylag;
            for i=1:nsamples
                % Add white noise
                temp = inputs.Results.mu + noise(:,i);
                % Add contribution from past values (i.e. Ylag)
                for p=1:obj.P
                    temp = temp + obj.A(:,:,p)*Ylag(:,p);
                end
                % Save new sample
                Y(:,obj.P+i) = temp;
                
                % Shift Ylags and include new sample
                % Also flip Ylags so that the coef matrix A_p aligns with
                % the right lag
                Ylag = fliplr(Y(:,i+1:obj.P+i));
            end

            % Remove initial conditions
            Y(:,1:obj.P) = [];
            
            % Normalize variance of each channel to unit variance
            Y_norm = Y./repmat(std(Y,0,2),1,nsamples);
        end
    end
    
end

