function data_file = tune_file_from_generator(outdir,varargin)

p = inputParser();
addRequired(p,'outdir',@ischar);
addParameter(p,'gen_params',{},@iscell);
addParameter(p,'gen_config_params',{},@iscell);
addParameter(p,'ntrials',1,@isnumeric);
parse(p,outdir,varargin{:});

var_gen = VARGenerator(p.Results.gen_params{:});
if var_gen.hasprocess
    fresh = false;
else
    var_gen.configure(p.Results.gen_config_params{:});
    fresh = true;
end
data_var = var_gen.generate('ntrials',p.Results.ntrials);

% [nchannels,nsamples,~] = size(data_var.signal_norm);

[~,data_name,~] = fileparts(var_gen.get_file());
data_file = fullfile(outdir,[data_name '-tuning.mat']);
if ~exist(data_file,'file') || fresh || isfresh(data_file,var_gen.get_file())
    save_parfor(data_file, data_var.signal_norm);
end

end