function [filter,ntrials] = exp30_get_filter(filter_type,varargin)

p = inputParser();
addParameter(p,'ntrials',1,@isnumeric)
addParameter(p,'nchannels',1,@isnumeric)
addParameter(p,'order',1,@isnumeric)
addParameter(p,'lambda',0.99,@isnumeric)
% addParameter(p,'gamma',1,@isnumeric)
parse(p,varargin{:});

switch filter_type
    case {'MQRDLSL1','MQRDLSL2','MLOCCDTWL'}
        if p.Results.ntrials > 1
            warning('this filter is a single trial filter');
        end
        ntrials = 1;
    case 'MCMTQRDLSL1'
        ntrials = p.Results.ntrials;
    otherwise
        error('unknown filter type %s',filter_type);
end

switch filter_type
    case 'MQRDLSL1'
        filter = MQRDLSL1(p.Results.nchannels,p.Results.order,p.Results.lambda);
    case 'MQRDLSL2'
        filter = MQRDLSL2(p.Results.nchannels,p.Results.order,p.Results.lambda);
    case 'MCMTQRDLSL1'
        filter = MCMTQRDLSL1(p.Results.ntrials,...
            p.Results.nchannels,p.Results.order,p.Results.lambda);
    case 'MLOCCDTWL'
        ntime = 358;
        sigma = 10^(-1);
        % gamma = sqrt(2*sigma^2*ntime*log(norder*nchannels^2));
        gamma = sqrt(2*sigma^2*ntime*log(p.Results.nchannels));
        filter = MLOCCD_TWL(p.Results.nchannels,p.Results.order,...
            'lambda',p.Results.lambda,'gamma',gamma);
    otherwise
        error('unknown filter type %s',filter_type);
end

end
