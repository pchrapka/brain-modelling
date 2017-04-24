classdef VRC < VARProcess
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
            obj.Kf = zeros(order,K,K);
            obj.Kb = zeros(order,K,K);
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
                    obj.P, obj.K, obj.K);
            end
            
            % Kb
            if isequal(size(Kb),size(obj.Kb))
                obj.Kb = Kb;
            else
                error([mfilename ':ParamError'],...
                    'bad size, should be [%d %d %d]',...
                    obj.P, obj.K, obj.K);
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
            %   structure (string, default = 'all')
            %       type of structure assumed for sparse model
            %       all - all coefficients are considered randomly
            %       fullchannels - generates a random sparse AR process in
            %       each channel, with random couplings
            %       
            %   structure = fullchannels
            %   ncouplings (integer, default = 0)
            %       number of coupling coefficients to be nonzero
            %   
            %   mode (string, default = probability)
            %       method to select number of coefficients: 'probability'
            %       and 'exact'
            %       probability - sets the probability of a coefficient
            %       being nonzero, requires probability parameter
            %       exact - sets the exact number of coefficients to be
            %       nonzero, requires ncoefs parameter
            %
            %   mode = probability
            %   probability
            %       probability of a coefficient being nonzero
            %       required when mode = 'probability'
            %
            %   mode = exact
            %   ncoefs (integer)
            %       number of coefficients to be nonzero
            %       required when mode = 'exact'
            %
            %   stable (logical, default = false)
            %       generates a stable process
            %   verbose (integer, default = 0)
            %       toggles verbosity of function
            
            p = inputParser;
            params_mode = {'probability','exact'};
            addParameter(p,'mode','probability',@(x) any(validatestring(x,params_mode)));
            params_struct = {'all','fullchannels'};
            addParameter(p,'structure','all',@(x) any(validatestring(x,params_struct)));
            addParameter(p,'probability',0.1,@isnumeric);
            addParameter(p,'ncoefs',0,@isnumeric);
            addParameter(p,'ncouplings',0,@isnumeric);
            addParameter(p,'stable',false,@islogical);
            addParameter(p,'max_order',false,@islogical);
            addParameter(p,'verbose',0,@isnumeric);
            parse(p,varargin{:});
            
            switch p.Results.structure
                case 'all'
                    obj.coefs_gen_sparse_all(varargin{:});
                case 'fullchannels'
                    obj.coefs_gen_sparse_fullchannels(varargin{:});
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
            
            stable = false;
            if nargin < 2
                verbose = false;
            end
            
            if obj.init
                method = 'ar';
                switch method
                    case 'sim'
                        % simulate some data
                        [x,~,~] = obj.simulate(3000);
                        x_max = max(abs(x(:)));
                        thresh = 5;
                        
                        % check signal max
                        if x_max > thresh
                            if verbose
                                fprintf('unstable VRC\n');
                                disp(x_max);
                            end
                            stable = false;
                        else
                            if verbose
                                fprintf('stable VRC\n');
                            end
                            stable = true;
                        end
                    case 'ar'
                        A1 = rc2ar(obj.Kf,obj.Kb);
                        A = rcarrayformat(A1,'format',3,'transpose',false);
                        var_obj = VAR(obj.K, obj.P);
                        var_obj.coefs_set(A);
                        stable = var_obj.coefs_stable();
                        if verbose
                            if stable
                                fprintf('stable VRC\n');
                            else
                                fprintf('unstable VRC\n');
                            end
                        end
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
        
        function rc_time = get_coefs_vs_time(obj, nsamples, coefs)
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
            p.addRequired('nsamples', @(x) x > 0);
            p.addRequired('coefs',@(x) any(validatestring(x,{'Kf','Kb'})));
            p.parse(nsamples,coefs);
            
            rc_time = repmat(shiftdim(obj.(coefs),-1),[nsamples,1,1,1]);
            
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
                    ferror(:,p-1) = ferror(:,p) + squeeze(obj.Kb(p-1,:,:))'*berrord(:,p-1);
                    berror(:,p) = berrord(:,p-1) - squeeze(obj.Kf(p-1,:,:))'*ferror(:,p-1);
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
        
        function plot(obj,varargin)
            p = inputParser();
            addParameter(p,'interactive',true,@islogical);
            addParameter(p,'ntrials',[],@isnumeric);
            parse(p,varargin{:});
            
            nsamples = 2000;
            [data,~,~] = obj.simulate(nsamples);
            
            figure;
            ncols = 2;
            nrows = ceil(obj.K/ncols);
            for j=1:obj.K
                subplot(nrows, ncols, j);
                plot(1:nsamples, data(j,:));
            end
        end
    end
    
    methods (Access = protected)
        function coefs_gen_sparse_all(obj, varargin)           
            p = inputParser;
            params_mode = {'probability','exact'};
            addParameter(p,'mode','probability',@(x) any(validatestring(x,params_mode)));
            addParameter(p,'structure','all',@(x) isequal(x,'all'));
            addParameter(p,'probability',0.1,@isnumeric);
            addParameter(p,'ncoefs',0,@isnumeric);
            addParameter(p,'stable',false,@islogical);
            addParameter(p,'max_order',false,@islogical);
            addParameter(p,'verbose',0,@isnumeric);
            parse(p,varargin{:});
            
            % reset coefs
            obj.Kf = zeros(obj.P,obj.K,obj.K);
            obj.Kb = zeros(obj.P,obj.K,obj.K);
            
            ncoefs = numel(obj.Kf);
            flag_run = true;
            while flag_run
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
                idx_hier = reshape(idx,obj.P,obj.K,obj.K);
                
                if p.Results.max_order
                    % make sure that there is at least one coefficient in
                    % the last order
                    idx_max = idx_hier(end,:,:);
                    if any(idx_max(:))
                        flag_run = false;
                    end
                else
                    % move on
                    flag_run = false;
                end
            end
            
            % interval for uniform distribution
            a = -1;
            b = 1;
            
            if p.Results.stable
                % randomly assign coefficient values one order at a time
                % this makes it a bit easire to get something stable for
                % higher orders
                max_iters = 200;
                i = 1;
                while (i <= obj.P)
                    if p.Results.verbose > 0
                        fprintf('working on order %d\n',i);
                    end
                    
                    stable = false;
                    scaling = 1;
                    iters = 1;
                    
                    while ~stable && (iters <= max_iters)
                        % get new coefs for current order
                        coefs_rand = scaling*unifrnd(a,b,obj.K,obj.K);
                        coefs_rand(~idx_hier(i,:,:)) = 0;
                        
                        % select coefs according to random index
                        obj.Kf(i,:,:) = coefs_rand;
                        
                        % set up a new object of order i
                        s = VRC(obj.K, i);
                        s.coefs_set(obj.Kf(1:i,:,:),obj.Kf(1:i,:,:));
                        
                        % check stability
                        stable = s.coefs_stable(false);
                        
                        % make sampling interval smaller, so we can
                        % converge to something
                        scaling = 0.99*scaling;
                        
                        iters = iters + 1;
                    end
                    
                    if stable
                        if p.Results.verbose > 0
                            fprintf('got order %d, scaling %0.2f\n',i,scaling);
                        end
                        % increment order
                        i = i+1;
                    else
                        % start over
                        i = 1;
                    end

                end
            else
                % randomly assign coefficient values from uniform distribution
                nidx = sum(idx);
                obj.Kf(idx) = a + (b-a).*rand(nidx,1);
            end
                    
            % copy coefficients
            for i=1:obj.P
                obj.Kb(i,:,:) = squeeze(obj.Kf(i,:,:))';
            end
        end
        
        function coefs_gen_sparse_fullchannels(obj,varargin)
            p = inputParser;
            params_mode = {'probability','exact'};
            addParameter(p,'mode','probability',@(x) any(validatestring(x,params_mode)));
            addParameter(p,'structure','fullchannels',@(x) isequal(x,'fullchannels'));
            addParameter(p,'probability',0.1,@isnumeric);
            addParameter(p,'ncoefs',0,@isnumeric);
            addParameter(p,'ncouplings',0,@isnumeric);
            addParameter(p,'stable',false,@islogical);
            addParameter(p,'max_order',false,@islogical);
            addParameter(p,'verbose',0,@isnumeric);
            parse(p,varargin{:});
            
            a = -1;
            b = 1;
            
            ncoefs_channel = p.Results.ncoefs - p.Results.ncouplings;
            if p.Results.stable
                
                obj.init = true;
                
                flag_restart = false;
                stable = false;
                while ~stable || flag_restart
                    flag_restart = false;
                    
                    % reset coefs
                    obj.Kf = zeros(obj.P,obj.K,obj.K);
                    obj.Kb = zeros(obj.P,obj.K,obj.K);
                    
                    flag_run = true;
                    while flag_run
                        % generate sparse coefs for each channel
                        for i=1:obj.K
                            fprintf('working on channel %d\n',i);
                            var1 = VRC(1,obj.P);
                            switch p.Results.mode
                                case 'probability'
                                    var1.coefs_gen_sparse(...
                                        'structure','all',...
                                        'mode','probability',...
                                        'probability',p.Results.probability,...
                                        'stable',true);
                                case 'exact'
                                    ncoefs_perchannel = floor(ncoefs_channel / obj.K);
                                    var1.coefs_gen_sparse(...
                                        'structure','all',...
                                        'mode','exact',...
                                        'ncoefs',ncoefs_perchannel,...
                                        'stable',true);
                            end
                            obj.Kf(:,i,i) = var1.Kf;
                            obj.Kb(:,i,i) = var1.Kb;
                        end
                        
                        if p.Results.max_order
                            % make sure that there is at least one coefficient in
                            % the last order
                            order_max = obj.Kf(end,:,:);
                            if any(order_max(:))
                                flag_run = false;
                            end
                        else
                            % move on
                            flag_run = false;
                        end
                    end
                    
                    % get indices of potential couplings
                    idx = true(size(obj.Kf));
                    for i=1:obj.K
                        idx(:,i,i) = false(obj.P,1);
                    end
                    % randomly select coupling indices
                    idx_couplings = find(idx);
                    idx_couplings_sel = randsample(idx_couplings,p.Results.ncouplings);
                    idx = false(size(obj.Kf));
                    idx(idx_couplings_sel) = true;
                    
                    for i=1:obj.P
                        fprintf('working on order %d\n',i);
                        idx_order = idx(i,:,:);
                        ncouplings_order = sum(idx_order(:));
                        if ncouplings_order == 0
                            % move on to next order
                            continue;
                        end
                        % set some vars
                        stable_coupling = false;
                        scaling = 1;
                        
                        % set number of attempts
                        iters = 1;
                        max_iters = 200;
                        
                        progbar = ProgressBar(max_iters);
                        while ~stable_coupling  && (iters <= max_iters)
                            progbar.progress();
                            % sample all couplings at once
                            coefs_new = scaling*unifrnd(a,b,[ncouplings_order, 1]);
                            obj.Kf(i,idx_order) = coefs_new;
                            obj.Kb(i,idx_order) = coefs_new;
                            
                            % check coupling stability
                            stable_coupling = obj.coefs_stable(false);
                            
                            % make sampling interval smaller, so we can
                            % converge to something
                            scaling = 0.99*scaling;
                            
                            iters = iters+1;
                        end
                        progbar.stop();
                        
                        if ~stable_coupling
                            flag_restart = true;
                            break;
                        end 
                    end
                    
                    
%                     coupling_count = 0;
%                     while coupling_count < p.Results.ncouplings
%                         coupled_channels = randsample(1:obj.K,2);
%                         coupled_order = randsample(1:obj.P,1);
%                         
%                         % check if we've already chosen this one
%                         if obj.Kf(coupled_order,coupled_channels(1),coupled_channels(2)) == 0
%                             
%                             stable_coupling = false;
%                             scaling = 1;
%                             iters = 1;
%                             max_iters = 200;
%                             while ~stable_coupling  && (iters <= max_iters)
%                                 % generate a new coefficient
%                                 coef_new = scaling*unifrnd(a, b);
%                                 obj.Kf(coupled_order,coupled_channels(1),coupled_channels(2))...
%                                     = coef_new;
%                                 obj.Kb(coupled_order,coupled_channels(1),coupled_channels(2))...
%                                     = coef_new;
%                                 
%                                 % check coupling stability
%                                 stable_coupling = obj.coefs_stable(false);
%                                 
%                                 % make sampling interval smaller, so we can
%                                 % converge to something
%                                 scaling = 0.99*scaling;
%                                 
%                                 iters = iters+1;
%                             end
%                             
%                             if stable_coupling
%                                 % increment counter
%                                 coupling_count = coupling_count + 1;
%                                 if p.Results.verbose > 0
%                                     fprintf('%d/%d couplings\n',coupling_count,p.Results.ncouplings);
%                                 end
%                             else
%                                 % reset coefficient
%                                 obj.Kf(coupled_order,coupled_channels(1),coupled_channels(2)) = 0;
%                                 obj.Kb(coupled_order,coupled_channels(1),coupled_channels(2)) = 0;
%                             end
%                             
%                         end
%                     end
                    
                    % check stability
                    stable = obj.coefs_stable(false);
                    
                end
                
            else
                error('not implemented');
            end
            
        end
    end
    
end

