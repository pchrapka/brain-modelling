classdef VAR < handle
    %VAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K;
        P;
        
        A;
    end
    
    properties(SetAccess = private)
        init = false;
    end
    
    methods
        function obj = VAR(K,p)
            %VAR constructor
            %   VAR(K,p) creates a VAR object with order p and dimension K
            %
            %   Input
            %   -----
            %   K (integer)
            %       process dimension
            %   p (integer)
            %       model order
            
            obj.K = K;
            obj.P = p;
            obj.A = zeros(K,K,p);
        end
        
        function coefs_set(obj,A)
            %COEFS_SET sets coefficients of VAR process
            %   COEFS_SET(OBJ, A)
            %
            %   Input
            %   -----
            %   A (matrix)
            %       VAR coefficients of size [K K P]
            
            if isequal(size(A),[obj.K, obj.K, obj.P])
                obj.A = A;
                obj.init = true;
            else
                disp(size(A))
                error('bad size, should be [%d %d %d]',...
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
                    
                    lambda = 2.5;
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
        
        function coefs_check(obj)
            %COEFS_CHECK checks VAR coefficients for stability
            %   COEFS_CHECK(OBJ) checks VAR coefficients for stability
            %
            %   References
            %   [1] J. D. Hamilton, Time series analysis, vol. 2. Princeton
            %   university press Princeton, 1994.
            %   	Equation (10.1.10)
            %   [2] H. Lütkepohl, New Introduction to Multiple Time Series
            %   Analysis. Springer Berlin Heidelberg, 2005.
            %       Equation (2.1.9)

            
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
            
            % Get eigenvalues
            lambda = eig(F);
            disp(lambda);
            disp(abs(lambda));
            
            % Check eigenvalues
            if max(abs(lambda)) >= 1
                fprintf('unstable VAR\n');
                disp(abs(lambda));
                error('eigenvalues larger than 1');
            else
                fprintf('stable VAR\n');
            end
        end
        
        function [Y,Y_norm, noise] = simulate(obj, nsamples, varargin)
            %SIMULATE simulate VAR process
            %   [Y,Y_norm,noise] = SIMULATE(obj, nsamples, [mu])
            %
            %   Input
            %   -----
            %   nsamples (integer)
            %       number of samples
            %   mu (vector, optional)
            %       mean of VAR process, default is zero
            %
            % Source: http://www.kris-nimark.net/pdf/Handout_S1.pdf
            
            if ~obj.init
                error('no coefficients set');
            end
            
            % Get the mean
            if nargin > 2
                v = varargin{1};
            else
                v = zeros(obj.K,1);
            end
            
            Sigma = eye(obj.K);
            
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
                temp = v + noise(:,i);
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
