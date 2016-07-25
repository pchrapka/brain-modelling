classdef VARConstAndPulse < VARProcess
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        process_const; % constant VAR process
        process_pulse; % pulse VAR process
        changepoints;  % on and off samples points for pulse
    end
    
    properties(SetAccess = private)
        init;
    end
    
    methods
        function obj = VARConstAndPulse(K,order,changepoints)
            %VARConstAndPulse constructor
            %   VARConstAndPulse(K,p,changepoints) creates a
            %   VARConstAndPulse object
            %
            %   Input
            %   -----
            %   K (integer)
            %       process dimension
            %   order (integer)
            %       model order
            %   changepoints (vector, length 2)
            %       samples at which the pulse turns on and off
            
            p = inputParser();
            p.addRequired('changepoints',@(x) length(x) == 2);
            p.parse(changepoints);
            
            obj.process_const = VAR(K,order);
            obj.process_pulse = VAR(K,order);
            obj.changepoints = changepoints;
        end
        
        function coefs_set(obj,A,process)
            %COEFS_SET sets coefficients of process
            %   COEFS_SET(obj, A, process)
            %
            %   Input
            %   -----
            %   A (matrix)
            %       AR coefficients of size [K K P]
            %   process (string)
            %       selects AR component to modify, options: const or pulse
            
            switch process
                case 'const'
                    obj.process_const.coefs_set(A);
                case 'pulse'
                    obj.process_pulse.coefs_set(A);
                otherwise
                    error('unknown process');
            end
            
            obj.init = obj.process_const.init & obj.process_pulse.init;
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
        end
        
        function coefs_gen(obj)
            %COEFS_GEN generates coefficients of VAR process
            %   COEFS_GEN(OBJ)
            
            error('todo');
        end
        
        function coefs_gen_sparse(obj,varargin)
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
            
            error('todo');
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
            
            stable = obj.process_const.coefs_stable(verbose) &&...
                obj.process_pulse.coefs_stable(verbose);
        end
        
        function [Y,Y_norm,noise] = simulate(obj, nsamples, varargin)
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
            
            if ~obj.init
                error('no coefficients set');
            end
            
            if nsamples < obj.changepoint(1)
                [Y,Y_norm,noise] = obj.process_const.simulate(nsamples,varargin{:});
            else
                K = obj.process_const.K;
                P = obj.process_const.P;
                
                inputs = inputParser;
                addOptional(inputs,'mu',zeros(K,1),@isnumeric);
                addOptional(inputs,'sigma',0.1,@isnumeric);
                parse(inputs,varargin{:});
                
                Sigma = inputs.Results.sigma*eye(K);
                
                % Generate initial conditions Y^{-p+1} ... Y^{0}
                Ylag = zeros(K,P);
                for p=1:P
                    Ylag(:,p) = mvnrnd(zeros(K,1), Sigma)';
                end
                
                % generate noise
                noise = mvnrnd(zeros(K,1), Sigma, nsamples)';
                
                % Generate the process
                Y = zeros(K,nsamples);
                Y(:,1:P) = Ylag;
                for i=1:nsamples
                    switch i
                        case obj.changepoint(1)
                            A = obj.process_pulse.A;
                        case obj.changepoint(2)
                            A = obj.process_const.A;
                    end
                    
                    % Add white noise
                    temp = inputs.Results.mu + noise(:,i);
                    % Add contribution from past values (i.e. Ylag)
                    for p=1:P
                        temp = temp + A(:,:,p)*Ylag(:,p);
                    end
                    % Save new sample
                    Y(:,P+i) = temp;
                    
                    % Shift Ylags and include new sample
                    % Also flip Ylags so that the coef matrix A_p aligns with
                    % the right lag
                    Ylag = fliplr(Y(:,i+1:P+i));
                end
                
                % Remove initial conditions
                Y(:,1:P) = [];
                
                % Normalize variance of each channel to unit variance
                Y_norm = Y./repmat(std(Y,0,2),1,nsamples);
            end
        end
    end
    
end

