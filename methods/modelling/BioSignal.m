classdef BioSignal
    %BioSignal Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function signal = muscle(varargin)
            %MUSCLE(...) generates a muscle signal
            %   MUSCLE(...) generates a muscle signal
            %
            %   Parameters
            %   -----
            %   fs (default = 100)
            %       sampling frequency
            %   nsamples (default = 100)
            %       number of samples
            %   bw (default = 70)
            %       bandwidth
            %   fo (default = 70)
            %       center frequency
            %
            %   References
            %   ----------
            %   S. V. Narasimhan and D. N. Dutt, “Application of LMS
            %   adaptive predictive filtering for muscle artifact (noise)
            %   cancellation from EEG signals,” Computers & Electrical
            %   Engineering, vol. 22, no. 1, pp. 13–30, Jan. 1996.
            
            p = inputParser();
            addParameter(p,'fs',100,@isnumeric);
            addParameter(p,'nsamples',100,@isnumeric);
            addParameter(p,'bw',70,@isnumeric);
            addParameter(p,'fo',70,@isnumeric);
            parse(p,varargin{:});
            
            T = 1/p.Results.fs; % sampling period
            step = 1;%0.01;
            n = 0:step:p.Results.nsamples;%linspace(0,1,T);
            t = n*T;
            sigma = p.Results.bw/2;
            fo = p.Results.fo; % center frequency
            
            % impulse response
            signal = (1/(2*pi*fo))*(exp(-2*pi*sigma*T).^n).*sin(2*pi*fo*T*n);
        end
        
        function [signal,shift] = rand_time_shift(signal, mu, sigma)
            %   signal
            %       signal to perturb
            %   mu
            %       mean of time shift in samples
            %   sigma
            %       std dev of time shift in samples
            
            if size(signal,1) ~= 1
                signal = signal(:)';
            end
            
            shift = ceil(mvnrnd(mu,sigma));
            if shift < 0
                tail = repmat(signal(end),1,abs(shift));
                signal = [signal tail];
                signal(1:abs(shift)) = [];
            elseif shift > 0
                prefix = repmat(signal(1),1,shift);
                signal = [prefix signal];
                signal(end-shift+1:end) = [];
            end
        end
        
        function [signal,scale] = rand_scale(signal, mu, sigma)
            %   signal
            %       signal to perturb
            %   mu
            %       mean of time shift in samples
            %   sigma
            %       std dev of time shift in samples
            
            scale = mvnrnd(mu,sigma);
            signal = scale*signal;
        end
    end

end

