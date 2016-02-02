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

