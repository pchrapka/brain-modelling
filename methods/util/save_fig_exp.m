function save_fig_exp(mfilename,varargin)
%SAVE_FIG_EXP save figure from an experiment
%   SAVE_FIG_EXP(...) save figure from an experiment
%
%   Parameters
%   ----------
%   tag (string, default = '')
%       add a tag to file name, the file name is [date]-[mfile name]-[tag]
%   formats (cell array, default = {'png','eps'})
%       export formats for the figure
%   save_flag (boolean, default = true)
%       flag for actually capturing the image, useful if you want to
%       disable saving


p = inputParser;
addRequired(p,'mfilename',@ischar);
addParameter(p,'tag','',@ischar);
addParameter(p,'formats',{'png','eps'},@iscell);
addParameter(p,'save_flag',true,@islogical);
parse(p,mfilename,varargin{:});

if ~p.Results.save_flag
    return;
end

% get the experiment mfile info
[pathstr,filename,~] = fileparts(mfilename);

% create an img dir in the experiment dir
imgdir = fullfile(pathstr,'img');
if ~exist(imgdir,'dir')
    mkdir(imgdir);
end

% save the figure in the experiment dir with the experiment as the file
% name with an optional tag
file_name_date = [datestr(now, 'yyyy-mm-dd') '-' filename '-' p.Results.tag];
file_name_full = fullfile(imgdir,file_name_date);

% change background color
set(gcf, 'Color', 'w');

if exist('export_fig', 'file')
    % export fig in each format
    for i=1:length(p.Results.formats)
        export_fig(file_name_full, sprintf('-%s',p.Results.formats{i}));
    end
else
    error('cannot find export_fig');
end

end