%% reshape test
clc;

nsamples = 10;
order = 4;
nchannels = 3;

c = zeros(order,nchannels,nchannels);
    for p=1:order
        for ch1=1:nchannels
            for ch2=1:nchannels
                c(p,ch1,ch2) = 100*p + (ch1-1)*nchannels + ch2;
            end
        end
    end
squeeze(c(1,:,:))
squeeze(c(2,:,:))

%%
c1 = reshape(c, [order nchannels^2]);

squeeze(c1(1,:))
squeeze(c1(2,:))

%%
a = zeros(nsamples,order,nchannels,nchannels);
for t=1:nsamples
    for p=1:order
        for ch1=1:nchannels
            for ch2=1:nchannels
                a(t,p,ch1,ch2) = 1000*t + 100*p + (ch1-1)*nchannels + ch2;
            end
        end
    end
end
squeeze(a(1,1,:,:))
squeeze(a(1,2,:,:))
squeeze(a(2,2,:,:))

%%
a1 = reshape(a, [nsamples order nchannels^2]);

squeeze(a1(1,:,:))
squeeze(a1(2,:,:))

b1 = sum(a1,1);
size(b1)