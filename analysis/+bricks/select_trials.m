function select_trials(files_in,files_out,opt)
%SELECT_TRIALS selects trials from source analysis
%   SELECT_TRIALS selects trials from source analysis. formatted for use
%   with PSOM pipeline
%
%   files_in (cell array)
%       sourceanalysis files processed by ftb.BeamformerPatchTrial
%   files_out (cell array)
%       unique file names of selected individual trials, same length as the
%       number of trials to select
%   opt (cell array)
%       function options specified as name value pairs
%
%       Example:
%           opt = {'trials', 100, 'labels', {'std','odd'}};
%   
%   Parameters
%   ----------
%   trials (integer, default = 100)
%       number of trials to select randomly
%   labels (cell array)
%       label for each analysis

p = inputParser;
p.StructExpand = false;
addRequired(p,'files_in',@iscell);
addRequired(p,'files_out',@iscell);
addParameter(p,'labels',@iscell);
addParameter(p,'trials',100,@isnumeric);
parse(p,files_in,files_out,opt{:});

% check length of output files
if length(files_out) ~= p.Results.trials
    error('not enough output files');
end

for i=1:length(files_in)
    % load data
    temp = ftb.util.loadvar(files_in{i});
    
    % select trials from each analysis randomly
    idx_rand = randsample(1:length(temp), p.Results.trials);
    temp_rand = temp(idx_rand);
    
    % add labels
    [temp_rand.label] = deal(p.Results.labels{i});
    
    % save as individual trials
    parfor j=1:p.Results.trials
        % save the trial
        save_parfor(files_out{j},temp_rand(j));
    end
end

end