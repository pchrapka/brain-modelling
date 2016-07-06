function data = loadfile(filename,varargin)
%LOADFILE loads data from a file
%   data = LOADFILE(filename) loads data from FILENAME
%
%   data = LOADFILE(filename,varname) loads only variable VARNAME from
%   FILENAME

p = inputParser();
p.addRequired('filename',@ischar);
p.addOptional('varname','',@ischar);
p.parse(filename,varargin{:});

% fprintf('reading data from file ''%s''\n', filename);

if ~isempty(p.Results.varname)
    % load the single variable
    filecontent = load(p.Results.filename, p.Results.varname);
    data = filecontent.(p.Results.varname);
else
    % load everything
    filecontent = load(p.Results.filename);
    fields = filenames(filecontent);
    % make sure there is only one variable
    if length(fields) > 1
        error('there are %d variables in the file',length(fields));
    end
    data = filecontent.(fields{1});
end

end