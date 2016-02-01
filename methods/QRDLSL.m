classdef QRDLSL < handle
    %QRDLSL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = QRDLSL(obj, order,)
        end
        
        function obj = update(obj, x)
            %   x
            %       new measurement
            
            Bpower_new = zeros(M,1);
            Fpower_new = zeros(M,1);
            % missing Ferror for current iteration
            
            % Extract params from previous update
            % Berror,
            % gamma?
            % Berror comes from previous udpate
            for m=1:M
                
                % Adaptive Forward prediction
                % $XB * \PhiB = ZB$
                
                % TODO Missing vars
                % Ferror(m-1)
                % gamma(m-1)
                
                % Set up vars
                XB = zeros(2,3);
                XB(1,1) = sqrt(lambda*Bpower(m-1));
                XB(1,2) = Berror(m-1);
                XB(2,1) = sqrt(lambda)*conj(pf(m-1));
                XB(2,2) = Ferror(m-1);
                XB(3,2) = sqrt(gamma(m-1));
                
                Bpower_new(m-1) = lambda*Bpower(m-1) * Berror(m-1)*conj(Berror(m-1));
                
                cb = sqrt(lambda*Bpower(m-1))/sqrt(Bpower_new(m-1));
                sb = Berror(m-1)/sqrt(Bpower_new(m-1));
                PhiB = [ cb -sb; conj(sb) cb];
                
                % Compute
                ZB = XB*PhiB;
                
                % Extract vars
                pf_new(m-1) = conj(ZB(2,1)); % overwrite pf?
                Ferror(m) = ZB(2,2);
                gamma(m) = ZB(3,2)^2;
                Bpower = Bpower_new; % do whole vector outside of loop?
                
                % Forward prediction
                % $ XF * \PhiF = ZF$
                
                % TODO missing vars
                % Ferror(m-1)
                
                % Set up vars
                XF = zeros(2,2);
                XF(1,1) = sqrt(lambda*Fpower(m-1));
                XF(1,2) = Ferror(m-1);
                XF(2,1) = sqrt(lambda)*conj(pb(m-1));
                XF(2,2) = Berror(m-1);
                
                Fpower_new(m-1) = lambda*Fpower(m-1) + Ferror(m-1)*conj(Ferror(m-1));
                
                cf = sqrt(lambda*Fpower(m-1))/sqrt(Fpower_new(m-1));
                sf = Ferror(m-1)/sqrt(Fpower_new(m-1));
                PhiF = [ cf -sf; conj(sf) cf];
                
                % Compute
                ZF = XF*PhiF;
                
                % Extract vars
                pb_new(m-1) = ZF(2,1);
                Berror(m) = ZF(2,2);
                Fpower = Fpower_new; % do whole vector outside of loop?
                
                
            end
            
            
        end
    end
    
end

