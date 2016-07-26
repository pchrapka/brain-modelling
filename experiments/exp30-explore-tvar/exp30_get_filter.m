function [filter,ntrials] = exp30_get_filter(filter_type,nchannels)

ntime = 358;
order_est = 10;
lambda = 0.98;

sigma = 10^(-1);
% gamma = sqrt(2*sigma^2*ntime*log(norder*nchannels^2));
gamma = sqrt(2*sigma^2*ntime*log(nchannels));

switch filter_type
    case 'MQRDLSL1'
        filter = MQRDLSL1(nchannels,order_est,lambda);
        ntrials = 1;
    case 'MQRDLSL2'
        filter = MQRDLSL2(nchannels,order_est,lambda);
        ntrials = 1;
    case 'MCMTQRDLSL1'
        ntrials = 5;
        filter = MCMTQRDLSL1(ntrials,nchannels,order_est,lambda);
    case 'MLOCCDTWL'
        filter = MLOCCDTWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
        ntrials = 1;
end

end
