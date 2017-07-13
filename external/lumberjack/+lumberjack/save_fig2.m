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
addParameter(p,'formats',{},@iscell);
addParameter(p,'save_flag',true,@islogical);
addParameter(p,'engine','export_fig',@(x) any(validatestring(x,{'export_fig','matlab'})));
addParameter(p,'nodate',false,@islogical);
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
    if p.Results.nodate
        error('cannot have nodate and no tag');
    end
    file_name_date = [datestr(now, 'yyyy-mm-dd')];
else
    if p.Results.nodate
        file_name_date = p.Results.tag;
    else
        file_name_date = [datestr(now, 'yyyy-mm-dd') '-' p.Results.tag];
    end
end
file_name_full = fullfile(imgdir,file_name_date);

% change background color
set(gcf, 'Color', 'w');
formats = p.Results.formats;

switch p.Results.engine
    case 'export_fig'
        if isempty(formats)
            formats = {'png','eps'};
        end
        if exist('export_fig', 'file')
            % export fig in each format
            params_formats = cell(length(formats),1);
            for i=1:length(formats)
                params_formats{i} = sprintf('-%s',formats{i});
            end
            export_fig(file_name_full, params_formats{:}, '-depsc');
        else
            error('cannot find export_fig');
        end
    case 'matlab'
        if isempty(formats)
            formats = {'png','epsc'};
        end
        set(gcf,'PaperPositionMode','auto');
        for i=1:length(formats)
            if ~isempty(strfind(formats{i},'eps'))
                print(gcf, ['-d' formats{i}], [file_name_full '.eps']);
                %saveas(gcf, [file_name_full '.eps'], formats{i});
            else
                print(gcf, ['-d' formats{i}], [file_name_full '.' formats{i}]);
                %saveas(gcf, [file_name_full '.' formats{i}], formats{i});
            end
        end
end
        

end