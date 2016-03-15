function [in, out, opt] = psom_brick_template(in, out, opt)
% Template for creating psom bricks
%
% SYNTAX:
% [in, out, opt] = psom_brick_template(in, out, opt)
%
% _________________________________________________________________________
% INPUTS:
%
% in        
%   (structure) with the following fields:
%
%   data
%   (string) file name of data to be analyzed
%
% out
%   (structure) with the following fields:
%
%   data
%   (string, default 'data.mat')
%   file name for the output data
%
% opt           
%   (structure) with the following fields.
%
%   metric_name (string, default '')
%       name of metric to computer, choices include:
%           fft
%           gmfa
%
%   metric_options (struct)
%       options for the selected metric
%
%       'gmfa'
%
%
%       'fft'       
%
%   folder_out 
%      (string, default: 'head-models') If present, all default outputs 
%      will be created in the folder FOLDER_OUT. The folder needs to be 
%      created beforehand.
%
%   flag_verbose 
%      (boolean, default 1) if the flag is 1, then the function prints 
%      some infos during the processing.
%
%   flag_test 
%      (boolean, default 0) if FLAG_TEST equals 1, the brick does not do 
%      anything but update the default values in IN, OUT and OPT.
%           
% _________________________________________________________________________
% OUTPUTS:
%
% IN, OUT, OPT: same as inputs but updated with default values.
%              
% _________________________________________________________________________
% SEE ALSO:
% 
%
% _________________________________________________________________________
% COMMENTS:
%
% _________________________________________________________________________
% Copyright (c) Phil Chrapka, 2014
% Maintainer : Phil Chrapka, pchrapka@gmail.com
% See licensing information in the code.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntax
if ~exist('in','var')||~exist('out','var')||~exist('opt','var')
    error('lumberjack:brick',...
        'Bad syntax, type ''help %s'' for more info.', mfilename)
end
    
%% Options
fields_defs = {...
    'metric_name',      '';...
    'metric_options',   [];...
    'flag_verbose',     true;...
    'flag_test',        false;...
    'folder_out',       ''};
fields = {fields_defs{:,1}};
defaults = {fields_defs{:,2}};
if nargin < 3
    opt = psom_struct_defaults(struct(), fields, defaults);
else
    opt = psom_struct_defaults(opt, fields, defaults);
end

%% Check the output files structure
fields_defs = {...
    'data',          'gb_psom_omitted';...
    };
fields = {fields_defs{:,1}};
defaults = {fields_defs{:,2}};
out = psom_struct_defaults(out, fields, defaults);

%% Building default output names

if strcmp(opt.folder_out,'') % if the output folder is left empty, use the same folder as the input
    opt.folder_out = 'output';    
end

if isempty(out.data)
    out.data = fullfile(opt.folder_out, 'data.mat');
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the data
data_in = load(in.data);




%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end

if ~strcmp(out.data, 'gb_psom_omitted');
    save(out.data, 'data');
end

end