function data = adjust_snr(cfg, data)
%adjust_snr Adjusts the SNR of the signal based on the ensemble
%average
%   data = adjust_snr(cfg, data) adjusts the SNR of the ensemble
%   averaged data relative to the averaged noise
%
%   Input
%   -----
%   data
%       averaged data, output of ft_timelockanalysis
%   cfg.snr
%       desired snr level in dB
%
%   Noise data
%   cfg.noise
%       averaged noise data
%   cfg.noisefile
%       filename containing averaged noise data
%
%   cfg.inputfile
%       (optional) filename containing averaged data, alternative to data
%       argument
%   cfg.outputfile
%       (optional) filename for saving the output data

% Load data
if isfield(cfg, 'noisefile')
    noise = ftb.util.loadvar(cfg.noisefile);
else
    noise = cfg.noise;
end

if isfield(cfg, 'inputfile')
    data = ftb.util.loadvar(cfg.inputfile);
end

% Calculate the noise power
nchannels = size(noise.avg,1);
noise_power = ftb.power(noise.avg)/nchannels;


% Calculate the current signal power
signal_power = ftb.power(data.avg)/nchannels;

% Calculate the adjustment
alpha = sqrt(10^(cfg.snr/10)*noise_power/signal_power);
if isinf(alpha)
    fprintf(['SNR adjustment is infinite for signal.\n'...
        'Not adjusting signal SNR.\n'...
        'Check yourself.\n']);
else
    data.avg = data.avg*alpha;
end

% Save struct to outputfile
if isfield(cfg, 'outputfile')
    save(cfg.outputfile, 'data');
end

end