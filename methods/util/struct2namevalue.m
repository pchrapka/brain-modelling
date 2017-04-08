function namevalue = struct2namevalue(s,varargin)
%STRUCT2NAMEVALUE converts struct to name value pairs
%   params_list = STRUCT2NAMEVALUE(s) converts struct to name
%   value pairs
%
%   Input
%   -----
%   s (struct)
%       parameter struct
%
%   Parameter
%   ---------
%   fields (cell array of strings)
%       cell array of field names
%   
%   Output
%   ------
%   namevalue (cell array)
%       list of name value pairs

p = inputParser();
addRequired(p,'s',@isstruct);
addParameter(p,'fields',{},@iscell);
parse(p,s,varargin{:});

if ~isempty(p.Results.fields)
    % copy fields
    temp = copyfields(s,[],p.Results.fields);
    s = temp;
end

namevalue = [fieldnames(s) struct2cell(s)];
namevalue = reshape(namevalue',1,numel(namevalue));

    
end