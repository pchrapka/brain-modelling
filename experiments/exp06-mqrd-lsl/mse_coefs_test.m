%% mse_coefs_test

a = zeros(nsamples,order,nchannels,nchannels);
atrue = a;
for t=1:nsamples
    for p=1:order
        for ch1=1:nchannels
            for ch2=1:nchannels
                a(t,p,ch1,ch2) = 1000*t + 100*p + (ch1-1)*nchannels + ch2;
                atrue(t,p,ch1,ch2) = 1000*t + 100*p;
            end
        end
    end
end

mse_coefs(a,atrue,'channels');