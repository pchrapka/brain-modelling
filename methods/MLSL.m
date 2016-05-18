classdef MLSL < handle
    %MLSL Multichannel Least Squares Lattice algorithm
    %   The implementation is as described in Lewis1990
    %   TODO add source
    
    properties (SetAccess = protected)
        % filter variables
        Rfb;	% fb cross correlation
        Cf;     % forward correlation
        Cb;     % backward correlation
        
        gammad;      % delayed gamma^2
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
        function obj = MLSL(channels, order, lambda)
            %MLSL constructor for MLSL
            %   MLSL(ORDER, LAMBDA) creates a MLSL object
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

            obj.Rfb = zeroMat; % fb cross correlation
            obj.Cf = zeroMat; % forward correlation
            obj.Cb = zeroMat; % backward correlation
            
            obj.berrord = zeros(obj.nchannels, obj.order+1);
            obj.gammad = ones(obj.order+1, 1);

            zeroMat2 = zeros(obj.order, obj.nchannels, obj.nchannels);
            obj.Kb = zeroMat2;
            obj.Kf = zeroMat2;
            
            obj.name = sprintf('MLSL C%d P%d lambda=%0.2f',...
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
            
            if ~isequal(size(x), [obj.nchannels 1])
                error([mfilename ':update'],...
                    'samples do not match filter channels: %d %d',...
                    size(x,1), obj.nchannels);
            end
            
            % allocate mem
            zeroMat = zeros(obj.nchannels,obj.order+1); 
            ferror = zeroMat;
            berror = zeroMat;
            gamma = zeros(obj.order+1,1);
            
            p = 1;
            % ferror is always updated from the previous order, so we don't
            % need to save anything between iterations
            % ferror at order 0 is initialized to the input
            ferror(:,p) = x;
            
            % berror turns into the delayed signal at the end
            % berror at order 0 is initialized to the input
            berror(:,p) = x;
            
            % gammasq is initialized to 1 for order 0
            gamma(p) = 1;
            
            % loop through stages
            for p=2:obj.order+1
                if inputs.Results.verbosity > 1
                    fprintf('order %d\n', p-1);
                end
                
                % update correlations
                Rfb_old = squeeze(obj.Rfb(p,:,:));
                Rfb_new = obj.lambda*Rfb_old + ferror(:,p-1)*obj.berrord(:,p-1)'/obj.gammad(p-1);
                
                Cf_old = squeeze(obj.Cf(p,:,:));
                Cf_new = obj.lambda*Cf_old + ferror(:,p-1)*ferror(:,p-1)'/obj.gammad(p-1);
                
                Cb_old = squeeze(obj.Cb(p,:,:));
                Cb_new = obj.lambda*Cb_old + obj.berrord(:,p-1)*obj.berrord(:,p-1)'/obj.gammad(p-1);

                % calculate reflection coefficients
                Cf_inv = pinv(Cf_new);
                Kf_new = Cf_inv*Rfb_new;
                Kb_new = Rfb_new*pinv(Cb_new);
                
                % update errors
                ferror(:,p) = ferror(:,p-1) - Kb_new*obj.berrord(:,p-1);
                berror(:,p) = obj.berrord(:,p-1) - Kf_new'*ferror(:,p-1);
                gamma(p) = obj.gammad(p-1) - ferror(:,p-1)'*Cf_inv*ferror(:,p-1);
                
                % calculate reflection coefficients
                obj.Kf(p-1,:,:) = Kf_new;
                obj.Kb(p-1,:,:) = Kb_new;
                
                % save vars
                obj.Rfb(p,:,:) = Rfb_new;
                obj.Cf(p,:,:) = Cf_new;
                obj.Cb(p,:,:) = Cb_new;
                
            end
            
            % save current values as delayed versions for next iteration
            obj.berrord = berror;
            obj.gammad = gamma;
            
        end
    end
    
end

