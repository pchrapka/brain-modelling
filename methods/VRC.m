classdef VRC < handle
    %VRC Vector Reflection Coefficient
    %   Detailed explanation goes here
    
    properties
        K; % process dimension
        P; % model order
        
        Kf; % forward coefficients
        Kb; % backward coefficients
    end
    
    properties(SetAccess = private)
        init = false;
    end
    
    methods
        function obj = VRC(K,order)
            %VRC constructor
            %   VRC(K,p) creates a VRC object with order p and dimension K
            %
            %   Input
            %   -----
            %   K (integer)
            %       process dimension
            %   order (integer)
            %       model order
            
            obj.K = K;
            obj.P = order;
            obj.Kf = zeros(K,K,order);
            obj.Kb = zeros(K,K,order);
        end
            
        
        function coefs_set(obj,Kf,Kb)
            %COEFS_SET sets coefficients of VRC process
            %   COEFS_SET(OBJ, Kf, Kb)
            %
            %   Input
            %   -----
            %   Kf (matrix)
            %       forward reflection coefficients of size [K K P]
            %   Kb (matrix)
            %       backward reflection coefficients of size [K K P]
            
            % Kf
            if isequal(size(Kf),size(obj.Kf))
                obj.Kf = Kf;
            else
                error([mfilename ':ParamError'],...
                    'bad size, should be [%d %d %d]',...
                    obj.K, obj.K, obj.P);
            end
            
            % Kb
            if isequal(size(Kb),size(obj.Kb))
                obj.Kb = Kb;
            else
                error([mfilename ':ParamError'],...
                    'bad size, should be [%d %d %d]',...
                    obj.K, obj.K, obj.P);
            end
            
            obj.init = true;
        end
        
        function coefs_gen(obj)
            %COEFS_GEN generates coefficients of VRC process
            %   COEFS_GEN(OBJ)
            
            error('todo');
            
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
            %COEFS_GEN_SPARSE generates coefficients of VRC process
            %   COEFS_GEN_SPARSE(OBJ, sparseness) generates coefficients of
            %   VRC process. this method has a better chance of finding a
            %   stable system with larger eigenvalues.
            %
            %   Parameters
            %   ----------
            %   mode (string, default = probability)
            %       method to select number of coefficients: 'probability'
            %       and 'exact'
            %
            %       'probability' - sets the probability of a coefficient
            %       being nonzero, requires probability parameter
            %
            %       'exact' - sets the exact number of coefficients to be
            %       nonzero, requires ncoefs parameter
            %   probability
            %       probability of a coefficient being nonzero, required
            %       when mode = 'probability'
            %   ncoefs (integer)
            %       number of coefficients to be nonzero, required when
            %       mode = 'exact'
            
            p = inputParser;
            params_mode = {'probability','exact'};
            addParameter(p,'mode','probability',@(x) any(validatestring(x,params_mode)));
            addParameter(p,'probability',0.1,@isnumeric);
            addParameter(p,'ncoefs',0,@isnumeric);
            parse(p,varargin{:});
            
            % reset coefs
            obj.Kf = zeros(obj.K,obj.K,obj.P);
            obj.Kb = zeros(obj.K,obj.K,obj.P);
            
            ncoefs = numel(obj.Kf);
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
                    
            
            % randomly assign coefficient values from uniform distribution
            % on interval [-1 1]
            nidx = sum(idx);
            a = -1;
            b = 1;
            obj.Kf(idx) = a + (b-a).*rand(nidx,1);
            for i=1:obj.P
                obj.Kb(:,:,i) = obj.Kf(:,:,i);
            end
            
            obj.init = true;
            
        end
        
        function stable = coefs_stable(obj,verbose)
            %COEFS_STABLE checks VRC coefficients for stability
            %   stable = COEFS_STABLE([verbose]) checks VRC coefficients for stability
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
            
            error('not sure how to check this');
            
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
                        fprintf('unstable VRC\n');
                        disp(abs(lambda));
                    end
                    stable = false;
                else
                    if verbose
                        fprintf('stable VRC\n');
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
            
            error('not sure how to do this');
            
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
        
        function [Y,Y_norm,noise] = simulate(obj, nsamples, varargin)
            %SIMULATE simulate VRC process
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
            %       simulated VRC process [channels, samples]
            %   Y_norm (matrix)
            %       simulated VRC process, with each channel normalized to
            %       unit variance [channels, samples]
            %   noise (matrix)
            %       driving white noise, [channels, samples]
            
            if ~obj.init
                error('no coefficients set');
            end
            
            inputs = inputParser;
            addOptional(inputs,'mu',zeros(obj.K,1),@isnumeric);
            addOptional(inputs,'sigma',0.1,@isnumeric);
            parse(inputs,varargin{:});
            
            % generate noise
            Sigma = inputs.Results.sigma*eye(obj.K);
            noise = mvnrnd(inputs.Results.mu, Sigma, nsamples)';
            
            % init mem
            zeroMat = zeros(obj.K, obj.P+1);
            ferror = zeroMat;
            berror = zeroMat;
            berrord = zeroMat;
            Y = zeros(obj.K, nsamples);
            
            for j=1:nsamples
                % input
                ferror(:,obj.P+1) = noise(:,j);
                
                % calculate forward and backward error at each stage
                for p=obj.P+1:-1:2
                    ferror(:,p-1) = ferror(:,p) + squeeze(obj.Kb(:,:,p-1))*berrord(:,p-1);
                    berror(:,p) = berrord(:,p-1) - squeeze(obj.Kf(:,:,p-1))'*ferror(:,p-1);
                    % Structure is from Haykin, p.179, sign convention is from
                    % Lewis1990
                end
                berror(:,1) = ferror(:,1);
                %     display(berror)
                %     display(ferror)
                
                % delay backwards error
                berrord = berror;
                
                % save 0th order forward error as output
                Y(:,j) = ferror(:,1);
            end
            
            % Normalize variance of each channel to unit variance
            Y_norm = Y./repmat(std(Y,0,2),1,nsamples);
        end
    end
    
end

