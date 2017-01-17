function outfile = run_ft_function(fname,config,varargin)
%RUN_FT_FUNCTION wrapper to run fieldtrip functions
%   RUN_FT_FUNCTION wrapper to run fieldtrip functions
%
%   run_ft_function(fname,config,...)
%
%   Input
%   -----
%   fname (string)
%       fieldtrip function name
%   config (struct)
%       fieldtrip function config
%   
%   Parameters
%   ----------
%   datain (struct/string, optional)
%       optional data input for fieldtrip function, can be specified as the
%       data struct or as a filename
%   dataidx (integer, optional)
%       index to select data from datain file
%
%   recompute (logical)
%       flag for recomputing data
%   save (logical)
%       flag for saving data, data file names are set based on fname
%   overwrite (logical)
%       flag for overwriting data if the data file exists
%   outpath (string)
%       output path for data files, only applies if save = true
%   tag (string, optional)
%       additional tag for the data file name
%

p = inputParser();
addRequired(p,'fname',@(x) ischar(x) && exist(x,'file'));
addRequired(p,'config',@isstruct);
addParameter(p,'datain','',@(x) isstruct(x) || ischar(x));
addParameter(p,'recompute',false,@islogical);
addParameter(p,'save',false,@islogical);
addParameter(p,'overwrite',false,@islogical);
addParameter(p,'outpath','',@ischar);
addParameter(p,'tag','',@ischar);
addParameter(p,'dataidx',0,@isnumeric);
parse(p,fname,config,varargin{:});

outfile = '';
if p.Results.save
    % generate outfile name
    tag = fname;
    if ~isempty(p.Results.tag)
        tag = [fname '-' p.Results.tag];
    end
    if isempty(p.Results.outpath)
        error('specify output path to save output');
    end
    outfile = fullfile(p.Results.outpath,sprintf('%s.mat',tag));
end


% check if it exists
if p.Results.save && exist(outfile,'file') && ~p.Results.recompute
    fprintf('%s output already exists\n',fname);
else
    params = {};
    if ~isempty(p.Results.datain)
        datain = p.Results.datain;
        if ischar(p.Results.datain)
            datain = ftb.util.loadvar(p.Results.datain);
        end
        if length(datain) > 1
            if p.Results.dataidx == 0
                error('choose which data input');
            end
            params = datain(p.Results.dataidx);
        else
            params = {datain};
        end
    end
    
    fh = str2func(fname);
    nout = nargout(fname);
    data = cell(nout,1);
    [data{:}] = fh(config,params{:});
    
    if p.Results.save
        save_tag(data, 'overwrite', p.Results.overwrite, 'outfile', outfile);
    end
end

end