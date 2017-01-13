function save_tag(data, varargin)

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
    outfile = p.Results.outfile;
else
    outfile = fullfile(p.Results.outpath,sprintf('%s.mat',p.Results.tag));
end

if exist(outfile,'file')
    if ~p.Results.overwrite
        error('file exists, choose another name or set flag to overwrite');
    end
end

save_parfor(outfile, data);

end