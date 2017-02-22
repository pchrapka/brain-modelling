function parfor_setup(varargin)
%PARFOR_SETUP sets up parallel pool for a given computer configuration
%   PARFOR_SETUP sets up parallel pool for a given computer configuration.
%   it only sets up a new parallel pool if there isn't one set up. you can
%   force it by using the flag.
%
%   Feel free to add a new configuration
%
%   Parameters
%   ----------
%   cores (integer)
%       number of cores to setup, if cores == 0 it defaults to the max for
%       that particular machine
%
%       blade = 12 for R2012a
%       blade = 20 for R2013b (untested)
%
%   force (logical, default = false)
%       flag to force opening a parallel pool with the specified number of
%       cores

p = inputParser();
addParameter(p,'cores',0,@isnumeric);
addParameter(p,'force',false,@islogical);
parse(p,varargin{:});

cores = p.Results.cores;
comp_name = get_compname();

switch comp_name
    case sprintf('blade16.ece.mcmaster.ca\n')
        
        if exist('parpool','file')
            if cores == 0
                % set default
                cores = 20;
            end
        else
            if cores == 0
                % set default
                cores = 12;
            end
        end
        
    otherwise
        if cores == 0
            cores = feature('numCores');
        end
        fprintf('%s: using default config with %d cores\n',mfilename,cores);
end


% set up parallel pool
fprintf('%s: setting up %d cores\n',mfilename,cores);
if exist('parpool','file')
    pool = gcp('nocreate');
    if isempty(pool)
        % set up a new one
        parpool('local', cores);
    elseif p.Results.force
        poolsize = pool.NumWorkers;
        if poolsize ~= cores
            % force a new one
            
            % close the current pool
            if ~isempty(pool)
                delete(pool);
            end
            
            % set up a new one
            parpool('local', cores);
        else
            fprintf('%s: already open\n',mfilename);
        end
    else
        fprintf('%s: already open\n',mfilename);
    end
else
    poolsize = matlabpool('size');
    if poolsize == 0
        % set up a new one
        matlabpool('open', cores);
    elseif p.Results.force
        if poolsize ~= cores
            % force a new one
            matlabpool('close');
            matlabpool('open', cores);
        else
            fprintf('%s: already open\n',mfilename);
        end
    else
        fprintf('%s: already open\n',mfilename);
    end
end

end