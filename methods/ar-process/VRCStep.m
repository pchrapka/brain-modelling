classdef VRCStep < VARProcess
    %VRCStep Vector Reflection Coefficient Process with Step Change
    %   Detailed explanation goes here
    
    properties
        process1; % VRC 1
        process2; % VRC 2
        changepoint; % sample at which process switches from process 1 to process 2
    end
    
    properties(SetAccess = private)
        init;
    end
    
    methods
        function obj = VRCStep(K,order,changepoint)
            %VRCStep constructor
            %   VRCStep(K,p) creates a VRCStep object with order p and
            %   dimension K
            %
            %   Input
            %   -----
            %   K (integer)
            %       process dimension
            %   order (integer)
            %       model order
            %   changepoint (integer)
            %       sample at which process switches from 1 to 2
            
            obj.process1 = VRC(K,order);
            obj.process2 = VRC(K,order);
            obj.changepoint = changepoint;
            
        end
        
        function coefs_set(obj,Kf,Kb,process)
            %COEFS_SET sets coefficients of VRC process
            %   COEFS_SET(OBJ, Kf, Kb)
            %
            %   Input
            %   -----
            %   Kf (matrix)
            %       forward reflection coefficients of size [K K P]
            %   Kb (matrix)
            %       backward reflection coefficients of size [K K P]
            
            switch process
                case 1
                    obj.process1.coefs_set(Kf,Kb);
                case 2
                    obj.process2.coefs_set(Kf,Kb);
                otherwise
                    error('unknown process');
            end
            
            obj.init = obj.process1.init & obj.process2.init;
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
            %COEFS_GEN generates coefficients of VRC process
            %   COEFS_GEN(OBJ)
            
            error('todo');
        end
        
        function coefs_gen_sparse(obj,varargin)
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
            
            obj.process1.coefs_gen_sparse(varargin{:});
            obj.process2.coefs_gen_sparse(varargin{:});
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
            
            stable = obj.process1.coefs_stable(verbose) &&...
                obj.process2.coefs_stable(verbose);
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
            
            if nsamples < obj.changepoint
                [Y,Y_norm,noise] = obj.process1.simulate(nsamples,varargin{:});
            else
                K = obj.process1.K;
                P = obj.process1.P;
                
                inputs = inputParser;
                addOptional(inputs,'mu',zeros(K,1),@isnumeric);
                addOptional(inputs,'sigma',0.1,@isnumeric);
                parse(inputs,varargin{:});
                
                % generate noise
                Sigma = inputs.Results.sigma*eye(K);
                noise = mvnrnd(inputs.Results.mu, Sigma, nsamples)';
                
                % init mem
                zeroMat = zeros(K, P+1);
                ferror = zeroMat;
                berror = zeroMat;
                berrord = zeroMat;
                Y = zeros(K, nsamples);
                
                Kf = obj.process1.Kf;
                Kb = obj.process1.Kb;
                
                for j=1:nsamples
                    if j==obj.changepoint
                        Kf = obj.process2.Kf;
                        Kb = obj.process2.Kb;
                    end
                    
                    % input
                    ferror(:,P+1) = noise(:,j);
                    
                    % calculate forward and backward error at each stage
                    for p=P+1:-1:2
                        ferror(:,p-1) = ferror(:,p) + squeeze(Kb(:,:,p-1))*berrord(:,p-1);
                        berror(:,p) = berrord(:,p-1) - squeeze(Kf(:,:,p-1))'*ferror(:,p-1);
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
    
end

