function data = gen_process(obj, process, varargin)
%
%   Input
%   -----
%   process (VAR or VRC object)
%       VAR or VRC object
%   
%   Parameter
%   ---------
%   nsamples (integer, default = 500)
%       number of samples

p = inputParser();
addRequired(p,'process');
addParameter(p,'nsamples',500,@isnumeric);
p.parse(process,varargin{:});

% generate data
data = [];
data.process = process;
data.signal = zeros(obj.nchannels, p.Results.nsamples, obj.nsims);
data.signal_norm = zeros(obj.nchannels, p.Results.nsamples, obj.nsims);
for j=1:obj.nsims
    % simulate process
    [signal,signal_norm,~] = process.simulate(p.Results.nsamples);
    
    data.signal(:,:,j) = signal;
    data.signal_norm(:,:,j) = signal_norm;
end

% save true coefficients
data.true = process.get_rc_time(p.Results.nsamples,'Kf');

end