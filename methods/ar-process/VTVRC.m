classdef VTVRC < VARProcess
    
    properties
        K; % process dimension
        P; % model order
        
        Kf; % forward coefficients
        Kb; % backward coefficients
        
        nsamples;
    end
    
    properties(SetAccess = private)
        init = false;
    end

    methods
        function obj = VTVRC(nchannels,norder,nsamples)
            %VTVRC constructor
            %   VTVRC(nchannels, norder, nsamples) creates a Vector
            %   Time-Varying Reflection Coefficient process
            %
            %   Input
            %   -----
            %   nchannels (integer)
            %       number of channels
            %   norder (integer)
            %       model order
            %   nsamples (integer)
            %       number of samples
            
            p = inputParser();
            addRequired(p,'nchannels',@isnumeric)
            addRequired(p,'norder',@isnumeric)
            addRequired(p,'nsamples',@isnumeric)
            parse(p,nchannels, norder, nsamples)
            
            obj.K = p.Results.nchannels;
            obj.P = p.Results.norder;
            obj.nsamples = p.Results.nsamples;
            
            obj.Kf = zeros(obj.nsamples, obj.P, obj.K, obj.K);
            obj.Kb = zeros(obj.nsamples, obj.P, obj.K, obj.K);
        end
        
        function coefs_set(obj,Kf,Kb)
            %COEFS_SET sets coefficients of VRC process
            %   COEFS_SET(OBJ, Kf, Kb)
            %
            %   Input
            %   -----
            %   Kf (matrix)
            %       forward reflection coefficients of size [N P K K]
            %   Kb (matrix)
            %       backward reflection coefficients of size [N P K K]
            
            % check dims
            dims = size(Kf);
            if ~isequal(dims,size(obj.Kf))
                fprintf('Kf input dims: \n');
                disp(dims)
                fprintf('required dims: \n');
                disp(size(obj.Kf));
                error([mfilename ':ParamError'], 'dims do not match');
            else
                obj.Kf = Kf;
            end
            
            dims = size(Kb);
            if ~isequal(dims,size(obj.Kb))
                fprintf('Kb input dims: \n');
                disp(dims)
                fprintf('required dims: \n');
                disp(size(obj.Kb));
                error([mfilename ':ParamError'], 'dims do not match');
            else
                obj.Kb = Kb;
            end
            
            obj.init = true;
        end
        
        function [Y,Y_norm, noise] = simulate(obj, nsamples, varargin)
            %SIMULATE simulate a VTVRC process
            %   [Y,Y_norm,noise] = SIMULATE(obj, nsamples, ...)
            %
            %   Input
            %   -----
            %   nsamples (integer)
            %       number of samples
            %
            %   Parameters
            %   ----------
            %   type_noise (string, default = 'generate')
            %       noise type, options include:
            %       generate 
            %           generates noise according to mu and sigma
            %       input
            %           uses noise input
            %
            %   type_noise = 'generate'
            %   mu (vector, optional)
            %       mean of VAR process, default is zero
            %   sigma (scalar, default = 0.1)
            %       variance of VAR process
            %
            %   type_noise = 'input'
            %   noise_input (matrix)
            %       input noise matrix of size [channels samples]
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
            addRequired(inputs,'nsamples',@(x) (x > 0) && (x <= obj.nsamples));
            addParameter(inputs,'type_noise','generate',...
                @(x) any(validatestring(x,{'generate','input'})))
            addParameter(inputs,'mu',zeros(obj.K,1),@isnumeric);
            addParameter(inputs,'sigma',0.1,@isnumeric);
            addParameter(inputs,'noise_input',[],...
                @(x) size(x) == [obj.nchannels obj.nsamples]);
            parse(inputs,varargin{:});
            
            switch p.Results.type_noise
                case 'generate'
                    % generate noise
                    Sigma = inputs.Results.sigma*eye(obj.K);
                    noise = mvnrnd(inputs.Results.mu, Sigma, nsamples)';
                case 'input'
                    noise = p.inputs.noise_input;
            end
            
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
                    ferror(:,p-1) = ferror(:,p) + squeeze(obj.Kb(j,p-1,:,:))'*berrord(:,p-1);
                    berror(:,p) = berrord(:,p-1) - squeeze(obj.Kf(j,p-1,:,:))'*ferror(:,p-1);
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
            Y_norm = normalizev(Y);
            
        end
        
        function coefs_time = get_coefs_vs_time(obj, nsamples, coefs)
        %GET_COEFS_VS_TIME returns the reflection coefficients over time
            %   GET_COEFS_VS_TIME(obj, nsamples, coefs) returns the reflection
            %   coefficients over time
            %
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
            addRequired(p,'nsamples', @(x) x > 0);
            addRequired(p,'coefs',@(x) any(validatestring(x,{'Kf','Kb'})));
            parse(p,nsamples,coefs);
            
            coefs_time = obj.(coefs)(1:nsamples,:,:,:);
            
        end
        
        function stable = coefs_stable(obj,varargin)
            %COEFS_STABLE checks VRC coefficients for stability
            %   stable = COEFS_STABLE([verbose]) checks VRC coefficients for stability
            %
            %   Parameters
            %   -----
            %   threshold (integer, default = 5)
            %       threshold of absolute value of signal that determines
            %       stability
            %   verbosity (boolean, optional)
            %       toggles verbosity of function, default = false
            %
            %   Output
            %   ------
            %   stable (boolean)
            %       true if stable, false otherwise
            
            p = inputParser();
            addParameter(p,'verbosity',false,@islogical);
            addParameter(p,'threshold',5,@isnumeric);
            parse(p,varargin{:});
            
            stable = false;
            if obj.init
                % uses the default generated noise to test stability
                [x,~,~] = obj.simulate(1000);
                x_max = max(abs(x(:)));
                
                if x_max > p.Results.threshold
                    if p.Results.verbosity
                        fprintf('unstable VTVRC\n');
                    end
                    stable = false;
                else
                    if p.Results.verbosity
                        fprint('stable VRC\n');
                    end
                    stable = true;
                end
            else
                error('no coefficients set')
            end
        end
        
        % abstract functions that have not been implemented
        function coefs_gen(obj)
            error('not implemented');
        end
        
        function coefs_gen_sparse(obj, varargin)
            error('not implemented');
        end
        
        function F = coefs_getF(obj)
            error('not implemented');
        end
            
    end


end