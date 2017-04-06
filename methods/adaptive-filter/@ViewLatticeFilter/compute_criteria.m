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

order_idx = order+1;

switch criteria
    case {'ewaic','ewsc'}
        % allocate mem
        cb = zeros(nsamples,1);
        cf = zeros(nsamples,1);
        lambda = obj.data.filter.lambda;

        delta = eps/nchannels;
        Vfprev = delta*eye(nchannels,nchannels);
        Vbprev = delta*eye(nchannels,nchannels);
        
        for j=1:nsamples
            
            % extract sample data
            [ferror,berror] = obj.get_error(order_idx,j);
            
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
            end
            
            
            cf(j) = log((1-lambda)/(1-lambda^n)) + logdet(Vf) + g;
            cb(j) = log((1-lambda)/(1-lambda^n)) + logdet(Vb) + g;
            
            Vfprev = Vf;
            Vbprev = Vb;
        end
        
    case 'normtime'
        % allocate mem
        cb = zeros(nsamples,1);
        cf = zeros(nsamples,1);
        
        for j=1:nsamples
            
            % extract sample data
            [ferror,berror] = obj.get_error(order_idx,j);
            
            % compute the magnitude over all channels and trials
            cf(j) = norm(ferror(:))/ntrials;
            cb(j) = norm(berror(:))/ntrials;
        end
        
    case {'aic','sc'}
        
        
        n = nsamples*ntrials;
        
        if ntrials > 1
            Vf = zeros(nchannels,nchannels);
            Vb = zeros(nchannels,nchannels);
            
            for j=1:nsamples
                % extract sample data
                [ferror,berror] = obj.get_error(order_idx,j);
                Vf = Vf + ferror*ferror'/n;
                Vb = Vb + berror*berror'/n;
            end
        else
            [ferror,berror] = obj.get_error(order_idx,[]);
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
        [ferror,berror] = obj.get_error(order_idx,[]);
        
        % compute the magnitude over all channels and trials
        cf = norm(ferror(:));
        cb = norm(berror(:));
        
    otherwise
        error('unknown criteria %s',criteria);
        
end

end


function out = logdet(A)
L = chol(A);
out = 2*sum(log(diag(L)));
end
