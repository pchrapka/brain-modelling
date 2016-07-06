function select_trials(files_in,files_out,opt)
%SELECT_TRIALS selects trials from source analysis
%   SELECT_TRIALS selects trials from source analysis. formatted for use
%   with PSOM pipeline
%
%   files_in (string)
%       file name of sourceanalysis file processed by ftb.BeamformerPatchTrial
%   files_out (cell array)
%       unique file names of selected individual trials, same length as the
%       number of trials to select
%   opt (cell array)
%       function options specified as name value pairs
%
%       Example:
%           opt = {'trials', 100, 'label', 'std'};
%   
%   Parameters
%   ----------
%   trials (integer, default = 100)
%       number of trials to select randomly
%   label (string)
%       label for data

p = inputParser;
p.StructExpand = false;
addRequired(p,'files_in',@ischar);
addRequired(p,'files_out',@iscell);
addParameter(p,'label','',@ischar);
addParameter(p,'trials',100,@isnumeric);
default_mode = {'random','consecutive'};
addParameter(p,'mode','random',@(x) any(validatestring(x,default_mode)));
parse(p,files_in,files_out,opt{:});

% check length of output files
if length(files_out) ~= p.Results.trials
    error('not enough output files');
end

% load data
temp = loadfile(files_in);

switch p.Results.mode
    case 'random'
        % select trials randomly
        idx_rand = randsample(1:length(temp), p.Results.trials);
        trials_sel = temp(idx_rand);
    case 'consecutive'
        % select consecutive trials
        trials_sel = temp(1:p.Results.trials);
end

% add labels
[trials_sel.label] = deal(p.Results.label);

% save as individual trials
parfor j=1:p.Results.trials
    % save the trial
    save_parfor(files_out{j},trials_sel(j));
end

end