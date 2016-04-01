function data = analysis_select_data(analysis,labels,varargin)
%ANALYSIS_SELECT_DATA selects trials randomly from beamformed data
%   ANALYSIS_SELECT_DATA(analysis,labels,...) selects trials randomly from
%   beamformed data
%   
%   Input
%   -----
%   analysis (cell array)
%       array of AnalysisBeamformer objects
%   labels (cell array)
%       label for each analysis
%   
%   Parameters
%   ----------
%   trials (integer)
%       number of trials to select randomly
%   
%   Output
%   ------
%   data (struct array)
%       array of source analysis structs, i.e. output of ft_sourceanalysis 

p = inputParser;
addRequired(p,'analysis');
addRequired(p,'labels',@iscell);
addParameter(p,'trials',100,@isnumeric);
parse(p,analysis,labels,varargin{:});

data = [];
for i=1:length(analysis)
    % load data
    temp = ftb.util.loadvar(analysis{i}.steps{6}.sourceanalysis);
    
    % select trials from each analysis randomly
    idx_rand = randsample(1:length(temp), p.Results.trials);
    temp_rand = temp(idx_rand);
    
    % add labels
    [temp_rand.label] = deal(labels{i});
    
    % concatenate data
    data = [data temp_rand];
    
end

end