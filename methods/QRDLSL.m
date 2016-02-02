classdef QRDLSL < handle
    %QRDLSL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % filter variables
        Berrord;
        Bpowerdd;
        Fpowerd;
        pbd;
        pfd;
        
        % reflection coefficients
        Kb;
        Kf;
        
        % filter order
        M;
        
        % weighting factor
        lambda;
    end
    
    methods
        function obj = QRDLSL(order, lambda)
            
            obj.M = order;
            obj.lambda = lambda;
            
            delta = 0.1; % small positive constant
            obj.Bpowerdd = delta*ones(obj.M+1,1);
            obj.Fpowerd = obj.Bpowerdd;
            
            zeroVec = zeros(obj.M,1);
            obj.Berrord = zeroVec;
            obj.pbd = zeroVec;
            obj.pfd = zeroVec;
            obj.Kb = zeroVec;
            obj.Kf = zeroVec;
        end
        
        function obj = update(obj, x)
            %   x
            %       new measurement
            
            % Mem allocation
            zeroVec = zeros(obj.M,1);
            Berror = zeroVec;
            Ferror = zeroVec;
            gammad = zeroVec;
            
            pf = zeroVec;
            pb = zeroVec;
            Bpowerd = zeroVec;
            Fpower = zeroVec;
            
            % Data initialization
            Berror(1) = x;
            Ferror(1) = x;
            gammad(1) = 1; % i'm assuming this is right
            
            for m=2:obj.M+1
                
                % Adaptive Forward prediction
                % $XB * \PhiB = ZB$
                
                % Set up vars
                XB = zeros(3,2);
                XB(1,1) = sqrt(obj.lambda*obj.Bpowerdd(m-1));
                XB(1,2) = obj.Berrord(m-1);
                XB(2,1) = sqrt(obj.lambda)*conj(obj.pfd(m-1));
                XB(2,2) = Ferror(m-1);
                XB(3,2) = sqrt(gammad(m-1));
                
                Bpowerd(m-1) = obj.lambda*obj.Bpowerdd(m-1) ...
                    + obj.Berrord(m-1)*conj(obj.Berrord(m-1));
                
                cb = sqrt(obj.lambda*obj.Bpowerdd(m-1))/sqrt(Bpowerd(m-1));
                sb = obj.Berrord(m-1)/sqrt(Bpowerd(m-1));
                PhiB = [ cb -sb; conj(sb) cb];
                
                % Compute
                ZB = XB*PhiB;
                
                % Extract vars
                pf(m-1) = conj(ZB(2,1)); % overwrite pf?
                Ferror(m) = ZB(2,2);
                gammad(m) = ZB(3,2)^2;
                
                obj.Kf(m) = -1*pf(m-1)/sqrt(Bpowerd(m-1));
                
                % Forward prediction
                % $ XF * \PhiF = ZF$
                
                % Set up vars
                XF = zeros(2,2);
                XF(1,1) = sqrt(obj.lambda*obj.Fpowerd(m-1));
                XF(1,2) = Ferror(m-1);
                XF(2,1) = sqrt(obj.lambda)*conj(obj.pbd(m-1));
                XF(2,2) = obj.Berrord(m-1);
                
                Fpower(m-1) = obj.lambda*obj.Fpowerd(m-1) ...
                    + Ferror(m-1)*conj(Ferror(m-1));
                
                cf = sqrt(obj.lambda*obj.Fpowerd(m-1))/sqrt(Fpower(m-1));
                sf = Ferror(m-1)/sqrt(Fpower(m-1));
                PhiF = [ cf -sf; conj(sf) cf];
                
                % Compute
                ZF = XF*PhiF;
                
                % Extract vars
                pb(m-1) = conj(ZF(2,1));
                Berror(m) = ZF(2,2);
                
                obj.Kb(m) = -1*pb(m-1)/sqrt(Fpower(m-1));
                
            end
            
            % Remove the first entry
            obj.Kf(1) = [];
            obj.Kb(1) = [];
            
            % Save vars for next update
            obj.pbd = pb; % i could overwrite pb
            obj.pfd = pf; % i could overwrite pf
            obj.Berrord = Berror;
            obj.Bpowerdd = Bpowerd;
            obj.Fpowerd = Fpower;
            
        end
    end
    
end

