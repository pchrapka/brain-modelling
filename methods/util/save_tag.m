function save_tag(data, varargin)
%
%   Input
%   -----
%   data
%       data to be saved
%
%   Parameters
%   ----------
%   tag (string)
%       tag for file name, default = output
%   outpath (string)
%       destination path for file
%   outfile (string)
%       file name for saved data, overrides tag and outpath
%   overwrite (logical, default = false)
%       flag to overwrite existing file

p = inputParser();
addParameter(p,'tag','output',@ischar);
addParameter(p,'outpath','',@ischar);
addParameter(p,'outfile','',@ischar);
addParameter(p,'overwrite',false,@islogical);
parse(p,varargin{:});

if isempty(p.Results.outpath) && isempty(p.Results.outfile)
    error('need to specify outpath or outfile');
end

if isempty(p.Results.outfile)
    outfile = fullfile(p.Results.outpath,sprintf('%s.mat',p.Results.tag));
else
    outfile = p.Results.outfile;
end

if exist(outfile,'file')
    if ~p.Results.overwrite
        error('file exists, choose another name or set flag to overwrite');
    end
end

save_parfor(outfile, data);

end