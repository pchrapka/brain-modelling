classdef GAL < handle
    %GAL Gradient Adaptive Lattice algorithm
    
    properties
        % Lattice filter vars
        M;  % M lattice order
        F;  % forward prediction error
        B;  % backward prediction error
        K;  % reflection coefficients
        
        beta;
        lambda;
        normB;
        normF;
        offset; % avoids a divde by 0
    end
    
    methods
        function obj = GAL(M, beta, lambda, d_init, offset)
            %
            %   d0
            %       initial prediction error power
            
            obj.M = M;
            obj.F = zeros(M+1,1);
            obj.B = zeros(M+1,1);
            obj.K = zeros(M,1);
            
            if nargin < 2
                obj.beta = 0.1;
            else
                obj.beta = beta;
            end
            if nargin < 3
                obj.lambda = 0.99;
            else
                obj.lambda = lambda;
            end
            if nargin < 4
                obj.normB = 0.1*ones(M+1,1);
                obj.normF = 0.1*ones(M+1,1);
            else
                obj.normB = d_init*ones(M+1,1);
                obj.normF = d_init*ones(M+1,1);
            end
            if nargin < 5
                obj.offset = 1;
            else
                obj.offset = offset;
            end
        end
        
        function update(obj, x)
            
            F = obj.F;
            B = obj.B;
            K = obj.K;
            
            % copy the previous backward errors
            Bdel = B;
            B(1) = x;
            F(1) = x;
            %print(obj);
            
            Knew = zeros(size(obj.K));
            lambda = obj.lambda;
            for j=1:obj.M
                % Hayes p. 528
                
%                 % update Dj
%                 obj.normB(j+1) = lambda*obj.normB(j+1) + (1-lambda)*Bdel(j)^2;
%                 obj.normF(j+1) = lambda*obj.normF(j+1) + (1-lambda)*F(j)^2;
                
                % update the errors
                F(j+1) = F(j) + K(j)*Bdel(j);
                B(j+1) = Bdel(j) + K(j)*F(j);
                
                % update the forward prediction power
                obj.normF(j+1) = lambda*obj.normF(j+1) + (1-lambda)*F(j)^2;
                
                % update the coefficient
                Knew(j) = K(j) - obj.beta*(F(j+1)*Bdel(j) + B(j+1)*F(j))/...
                    (obj.normB(j+1) + obj.normF(j+1) + obj.offset);
                %print(obj);
                %Knew
                
                % update the backward prediction power
                obj.normB(j+1) = lambda*obj.normB(j+1) + (1-lambda)*B(j)^2;

%                 % Friedlander 1982, GAL1
%                 Knew(j) = K(j) + obj.beta*(F(j+1)*Bdel(j+1) + B(j+1)*F(j))/...
%                     (obj.normB(j) + obj.normF(j) + obj.offset);
%                 F(j+1) = F(j) - Knew(j)*Bdel(j);
%                 B(j+1) = Bdel(j) - Knew(j)*F(j);
%                 obj.normB(j) = lambda*obj.normB(j) + (1-lambda)*Bdel(j)^2;
%                 obj.normF(j) = lambda*obj.normF(j) + (1-lambda)*F(j)^2;
            end
            
            % save vars
            obj.K = Knew;
            obj.B = B;
            obj.F = F;
        end
        
        function print(obj)
            names = fieldnames(obj);
            for i=1:length(names)
                fprintf('%s\n',names{i});
                if isvector(obj.(names{i}))
                    disp(obj.(names{i})');
                else
                    disp(obj.(names{i}));
                end
            end
        end
    end
end