classdef VRCConstAndPulse < VARProcess
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
        function obj = VRCConstAndPulse(K,order,changepoints)
            %VRCConstAndPulse constructor
            %   VRCConstAndPulse(K,p,changepoints) creates a
            %   VRCConstAndPulse object
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
            
            obj.process_const = VRC(K,order);
            obj.process_pulse = VRC(K,order);
            obj.changepoints = changepoints;
        end
        
        function coefs_set(obj,Kf,Kb,process)
            %COEFS_SET sets coefficients of process
            %   COEFS_SET(obj, Kf, Kb, process)
            %
            %   Input
            %   -----
            %   Kf (matrix)
            %       forward reflection coefficients of size [K K P]
            %   Kb (matrix)
            %       backward reflection coefficients of size [K K P]
            %   process (string)
            %       selects AR component to modify, options: const or pulse
            
            switch process
                case 'const'
                    obj.process_const.coefs_set(Kf,Kb);
                case 'pulse'
                    obj.process_pulse.coefs_set(Kf,Kb);
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
            
            error('todo');
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
            
            stable = obj.process_const.coefs_stable(verbose) &&...
                obj.process_pulse.coefs_stable(verbose);
        end
        
        function rc_time = get_rc_time(obj, nsamples, coefs)
            %   Input
            %   -----
            %   nsamples (integer)
            %       number of samples
            %   coefs (string)
            %       Kf or Kb
            %
            %   Output
            %   ------
            %   rc_time (matrix)
            %       reflection coefficients over time [samples P K K]
            
            p = inputParser();
            p.addRequired('nsamples', @(x) x > 0);
            p.addRequired('coefs',@(x) any(validatestring(x,{'Kf','Kb'})));
            p.parse(nsamples,coefs);
            
            rc_time = zeros(obj.process_const.P, obj.process_const.K,...
                obj.process_const.K, nsamples);
            
            % initialize rc_coefs
            rc_coefs = obj.process_const.(coefs);
            for j=1:nsamples
                switch j
                    case obj.changepoints(1)
                        rc_coefs = obj.process_pulse.(coefs);
                    case obj.changepoints(2)
                        rc_coefs = obj.process_const.(coefs);
                end
                
                rc_time(:,:,:,j) = shiftdim(rc_coefs,2);
                
            end
            
            rc_time = shiftdim(rc_time,3);
            
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
            %       mean of VRC process, default is zero
            %   sigma (scalar, default = 0.1)
            %       variance of VRC process
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
            
            if nsamples < obj.changepoints(1)
                [Y,Y_norm,noise] = obj.process_const.simulate(nsamples,varargin{:});
            else
                K = obj.process_const.K;
                P = obj.process_const.P;
                Kf = obj.process_const.Kf;
                Kb = obj.process_const.Kb;
                
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
                
                for j=1:nsamples
                    switch j
                        case obj.changepoints(1)
                            Kf = obj.process_pulse.Kf;
                            Kb = obj.process_pulse.Kb;
                        case obj.changepoints(2)
                            Kf = obj.process_const.Kf;
                            Kb = obj.process_const.Kb;
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

