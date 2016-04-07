function select_trials(files_in,files_out,opt)
%SELECT_TRIALS selects trials from source analysis
%   SELECT_TRIALS selects trials from source analysis. formatted for use
%   with PSOM pipeline
%
%   files_in (cell array)
%       sourceanalysis files from TODO
%   files_out (cell array)
%       file names selected individual trials
%   opt (cell array)
%       function options specified as name value pairs
%   
%   Parameters
%   ----------
%   trials (integer)
%       number of trials to select randomly
%   labels (cell array)
%       label for each analysis

p = inputParser;
p.StructExpand = false;
addParameter(p,'labels',@iscell);
addParameter(p,'trials',100,@isnumeric);
parse(p,opt{:});

for i=1:length(files_in)
    % load data
    temp = ftb.util.loadvar(files_in{i});
    
    % select trials from each analysis randomly
    idx_rand = randsample(1:length(temp), p.Results.trials);
    temp_rand = temp(idx_rand);
    
    % add labels
    [temp_rand.label] = deal(p.Results.labels{i});
    
    % save as individual trials
    for j=1:p.Results.ntrials
        data = temp_rand{i}; % TODO check this
        
        % TODO do this in beamforming step
        % save the trial
        save(files_out{j},'data');
    end
end

end