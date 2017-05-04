function [cf,cb] = compute_criteria(obj,criteria,order)

dims = size(obj.data.estimate.ferror);
nsamples = dims(1);
switch length(dims)
    case 4
        ntrials = dims(3);
        nchannels = dims(2);
    case 3
        ntrials = 1;
        nchannels = dims(2);
end

error_order_idx = order+1;

switch criteria
    case {'ewaic','ewsc','ewlogdet'}
        % allocate mem
        cb = zeros(nsamples,1);
        cf = zeros(nsamples,1);
        lambda = obj.data.filter.lambda;

        delta = 10*eps/nchannels;
        Vfprev = delta*eye(nchannels,nchannels);
        Vbprev = delta*eye(nchannels,nchannels);
        
        for j=1:nsamples
            
            % extract sample data
            [ferror,berror] = obj.get_error(error_order_idx,j);
            
            %Taylor, James W. "Exponentially weighted information criteria for
            %selecting among forecasting models." International Journal of
            %Forecasting 24.3 (2008): 513-524.
            
            Vf = lambda*Vfprev + ferror*ferror'/ntrials;
            Vb = lambda*Vbprev + berror*berror'/ntrials;
            
            n = j*ntrials;
            
            switch criteria
                case 'ewaic'
                    % Akaike
                    g = 2*order*nchannels^2/n;
                case 'ewsc'
                    % Bayesian Schwartz
                    g = log(n)*order*nchannels^2/n;
                case 'ewlogdet'
                    g = 0;
            end
            
            
            cf(j) = logdet((1-lambda)/(1-lambda^j)*Vf) + g;
            cb(j) = logdet((1-lambda)/(1-lambda^j)*Vb) + g;
            
            Vfprev = Vf;
            Vbprev = Vb;
        end
        
    case 'whitetime'
        % allocate mem
        cb = zeros(nsamples,1);
        cf = zeros(nsamples,1);
        lambda = obj.data.filter.lambda;
        
        Vfprev = zeros(nchannels,nchannels);
        Vbprev = zeros(nchannels,nchannels);
        
        for j=1:nsamples
            
            % extract sample data
            [ferror,berror] = obj.get_error(error_order_idx,j);
            
            Vf = lambda*Vfprev + ferror*ferror'/ntrials;
            Vb = lambda*Vbprev + berror*berror'/ntrials;
            
            weight = (1-lambda)/(1-lambda^j);
            Vf_weighted = abs(weight*Vf);
            Vb_weighted = abs(weight*Vb);
            
            % compute ratio of the main diagonal to sum of the column
            temp = diag(Vf_weighted)./sum(Vf_weighted,2);
            cf(j) = mean(temp);
            temp = diag(Vb_weighted)./sum(Vb_weighted,2);
            cb(j) = mean(temp);
        end
        
        
    case 'normerrortime'
        % allocate mem
        cb = zeros(nsamples,1);
        cf = zeros(nsamples,1);
        
        for j=1:nsamples
            
            % extract sample data
            [ferror,berror] = obj.get_error(error_order_idx,j);
            
            % compute the magnitude over all channels and trials
            cf(j) = norm2(ferror,ntrials);
            cb(j) = norm2(berror,ntrials);
        end
        
    case {'aic','sc'}
        
        
        n = nsamples*ntrials;
        
        if ntrials > 1
            Vf = zeros(nchannels,nchannels);
            Vb = zeros(nchannels,nchannels);
            
            for j=1:nsamples
                % extract sample data
                [ferror,berror] = obj.get_error(error_order_idx,j);
                Vf = Vf + ferror*ferror'/n;
                Vb = Vb + berror*berror'/n;
            end
        else
            [ferror,berror] = obj.get_error(error_order_idx,[]);
            Vf = ferror*ferror'/n;
            Vb = berror*berror'/n;
        end
        
        if ~isequal(size(Vf), [nchannels nchannels])
            error('something went wrong');
        end
        
        switch criteria
            case 'aic'
                % Akaike
                g = 2*order*nchannels^2/n;
            case 'sc'
                % Bayesian Schwartz
                g = log(n)*order*nchannels^2/n;
        end
        
        
        cf = logdet(Vf) + g;
        cb = logdet(Vb) + g;
        
    case 'norm'
        
        % extract sample data
        [ferror,berror] = obj.get_error(error_order_idx,[]);
        
        % compute the magnitude over all channels and trials
        cf = norm2(ferror,ntrials);
        cb = norm2(berror,ntrials);
        
    case 'sum_normerror_normcoefs_time'
        
        % allocate mem
        cb = zeros(nsamples,1);
        cf = zeros(nsamples,1);
        
        for j=1:nsamples
            
            % extract sample data
            [ferror,berror] = obj.get_error(error_order_idx,j);
            [Kf,Kb] = obj.get_coefs(order,j);
            
            % compute the magnitude over all channels and trials
            cf(j) = norm2(ferror,ntrials) + norm1(Kf);
            cb(j) = norm2(berror,ntrials) + norm1(Kb);
        end
        
    case 'norm1coefs_time'
        
        % allocate mem
        cb = zeros(nsamples,1);
        cf = zeros(nsamples,1);
        
        for j=1:nsamples
            
            % extract sample data
            [Kf,Kb] = obj.get_coefs(order,j);
            
            % compute the magnitude over all channels and trials
            cf(j) = norm1(Kf);
            cb(j) = norm1(Kb);
        end
        
    case 'minorigin_normerror_norm1coefs_time'
        
        % allocate mem
        cb = zeros(nsamples,1);
        cf = zeros(nsamples,1);
        
        for j=1:nsamples
            
            % extract sample data
            [ferror,berror] = obj.get_error(error_order_idx,j);
            [Kf,Kb] = obj.get_coefs(order,j);
            
            % compute the magnitude over all channels and trials
            cf(j) = norm([norm2(ferror,ntrials), norm1(Kf)]);
            cb(j) = norm([norm2(berror,ntrials), norm1(Kb)]);
        end
        
    case 'minorigin_deterror_norm1coefs_time'
        
        % allocate mem
        cb = zeros(nsamples,1);
        cf = zeros(nsamples,1);
        
        lambda = obj.data.filter.lambda;

        delta = eps/nchannels;
        Vfprev = delta*eye(nchannels,nchannels);
        Vbprev = delta*eye(nchannels,nchannels);
        
        for j=1:nsamples
            
            % extract sample data
            [ferror,berror] = obj.get_error(error_order_idx,j);
            [Kf,Kb] = obj.get_coefs(order,j);
            
            Vf = lambda*Vfprev + ferror*ferror'/ntrials;
            Vb = lambda*Vbprev + berror*berror'/ntrials;
            
            Vfdet = exp(logdet((1-lambda)/(1-lambda^j)*Vf));
            Vbdet = exp(logdet((1-lambda)/(1-lambda^j)*Vb));
            
            % compute the magnitude over all channels and trials
            cf(j) = norm([Vfdet, norm1(Kf)]);
            cb(j) = norm([Vbdet, norm1(Kb)]);
            
            Vfprev = Vf;
            Vbprev = Vb;
        end
        
    otherwise
        error('unknown criteria %s',criteria);
        
end

end

function out = norm2(value,ntrials)
out = norm(value(:))/ntrials;
end

function out = norm1(value)
out = norm(value(:),1);
end


function out = logdet(A)
L = chol(A);
out = 2*sum(log(diag(L)));
end
