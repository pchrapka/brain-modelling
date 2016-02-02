classdef BurgWindow < handle
    %BurgWindow windowed version of Burg's algorithm
    
    properties
        % filter order
        M;
        % window length
        nwindow;
        % sample buffer
        buffer;
        % weighting factor
        lambda;
        
        % reflection coefficients
        K;
    end
    
    methods
        function obj = BurgWindow(order, nwindow, lambda)
            %BurgWindow constructor for BurgWindow
            %   BurgWindow(ORDER, NWINDOW, [LAMBDA]) creates a BurgWindow object
            %
            %   order (integer)
            %       filter order
            %   nwindow (integer)
            %       length of dataa window to use for Burg's algorithm
            %   lambda (scalar)
            %       exponential weighting factor between 0 and 1
            
            if nargin < 3
                lambda = 0;
            end
            
            obj.M = order;
            obj.nwindow = nwindow;
            obj.lambda = lambda;
            
            obj.buffer = zeros(obj.nwindow,1);
            obj.K = zeros(obj.M,1);
        end
        
        function obj = update(obj,x)
            %UPDATE updates reflection coefficients
            %   UPDATE(OBJ,X) updates the reflection coefficients using the
            %   measurement X
            %
            %   x (scalar)
            %       new measurement
            
            % add the new measurement
            obj.buffer(1) = [];
            obj.buffer(end+1) = x;
            
            % compute reflection coefficients
            [~,~,Knew] = arburg(obj.buffer,obj.M);
            
            % smooth the reflection coefficients
            obj.K = obj.lambda*obj.K + (1-obj.lambda)*Knew;
            
            
        end
            
    end
    
end

