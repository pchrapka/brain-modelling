function outfiles = run_lattice_filters(file_data,varargin)
% runs multiple filters in parfor loop
%   Input
%   -----
%   datain (string)
%       filename that contains the data matrix or a struct with the field
%       data
%       data should have the size [channels time trials]
%
%   Parameters
%   ----------
%   filters (cell array)
%       cell array of filter objects
%   
%   remaining parameters are passed to run_lattice_filter, see it's help
%   section for more information
%
%   see also run_lattice_filter

p = inputParser();
p.KeepUnmatched = true;
addRequired(p,'file_data',@ischar);
addParameter(p,'filters',{},@iscell);
parse(p,file_data,varargin{:});

params = struct2namevalue(p.Unmatched);
nfilters = length(p.Results.filters);
filters = p.Results.filters;

outfiles_sub = cell(nfilters,1);
parfor i=1:nfilters
    outfiles_sub{i} = run_lattice_filter(...
        file_data,...
        'filter',filters{i},...
        params{:});
end

% collect output files
nfiles = length(outfiles_sub{1});
outfiles = reshape(outfiles_sub,[nfiles*nfilters 1]);

end