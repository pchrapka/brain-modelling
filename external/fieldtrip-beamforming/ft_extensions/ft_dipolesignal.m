function data = ft_dipolesignal( cfg )
%ft_dipolesignal Simulates brain sources for a multiple trials
%   ft_dipolesignal(cfg) simulates brain sources based on the parameters
%   specified in cfg, and returns the simulated data
%
%   Input
%   -----
%   cfg.ntrials
%       number of trials
%   cfg.triallength 
%       length of trial in seconds
%   cfg.fsample     
%       sampling frequency
%   cfg.type 
%       source type
%
%   source types: 
%
%   erp
%       The source is modeled as an evoked/event related potential. It's
%       generated using the PHASERESET.PEAK function from the phasereset
%       package.
%
%       type = 'erp'
%       amp         amplitude of signal
%       freq        frequency of signal (Hz)
%       pos         position of ERP (samples)
%       jitter      jitter in peak of ERP
%
%
%       
%   Output
%   ------
%   data
%       cell array containing an instance of the source for each trial
%       [trials x 1]

% Calculate number of samples
samples = cfg.triallength*cfg.fsample;

% Allocate memory
data = cell(cfg.ntrials,1);
for i=1:cfg.ntrials
    % Allocate memory
    data{i} = zeros(samples, 1);
    
    % Create sources
    switch cfg.type
        case 'erp'
            % Signal will be [1, timepoints]
            data{i} = cfg.amp *...
                phasereset.peak(...
                samples,...
                1,...
                cfg.fsample,...
                cfg.freq,...
                cfg.pos,...
                cfg.jitter);
    end
end

end