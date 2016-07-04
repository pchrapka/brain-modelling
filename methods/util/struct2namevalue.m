function param_list = struct2namevalue(param_struct)
%STRUCT2NAMEVALUE converts struct to name value pairs
%   params_list = STRUCT2NAMEVALUE(param_struct) converts struct to name
%   value pairs
%
%   Input
%   -----
%   param_struct (struct)
%       parameter struct
%   
%   Output
%   ------
%   param_list (cell array)
%       list of name value pairs

param_list = [fieldnames(param_struct) struct2cell(param_struct)];
param_list = reshape(param_list',1,numel(param_list));
end