function save_fig2(varargin)
%SAVE_FIG2 save a figure
%   SAVE_FIG2(...) save a figure
%
%   Parameters
%   ----------
%   path (string, default = pwd)
%       path for saving figures
%   tag (string, default = '')
%       add a tag to file name, the file name is [date]-[mfile name]-[tag]
%   formats (cell array, default = {'png','eps'})
%       export formats for the figure
%   save_flag (boolean, default = true)
%       flag for actually capturing the image, useful if you want to
%       disable saving


p = inputParser;
addParameter(p,'path',pwd(),@ischar);
addParameter(p,'tag','',@ischar);
addParameter(p,'formats',{'png','eps'},@iscell);
addParameter(p,'save_flag',true,@islogical);
parse(p,varargin{:});

if ~p.Results.save_flag
    return;
end

% create an img dir in the dir
imgdir = fullfile(p.Results.path,'img');
if ~exist(imgdir,'dir')
    mkdir(imgdir);
end

% save the figure in the experiment dir with the experiment as the file
% name with an optional tag
if isempty(p.Results.tag)
    file_name_date = [datestr(now, 'yyyy-mm-dd')];
else
    file_name_date = [datestr(now, 'yyyy-mm-dd') '-' p.Results.tag];
end
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