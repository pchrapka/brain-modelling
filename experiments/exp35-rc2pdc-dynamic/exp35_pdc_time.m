%% exp35_pdc_time

nchannels = 20;
norder = 10;
metric = 'euc';

channels = [5 10 20 40 100];
% channels = [5 10 20 30];
telapsed = zeros(size(channels));

sparsity = 0.2;

for i=1:length(channels)
    
    nchannels = channels(i);
    fprintf('channels %d\n',nchannels);

    %% set up random matrices
    
    nchoices = max([round(sparsity*nchannels) 1]);
    idx_ch1 = randsample(nchannels,nchoices);
    idx_ch2 = randsample(nchannels,nchoices);
    
    Kf = zeros(1,nchannels,nchannels,norder);
    for j=1:length(idx_ch1)
        for k=1:length(idx_ch2)
            Kf(1,idx_ch1(j),idx_ch2(k),:) = rand(norder,1);
        end
    end
    Kb = Kf;
    
    %% dynamic pdc prep
    
    Kftemp = squeeze(Kf(1,:,:,:));
    Kbtemp = squeeze(Kb(1,:,:,:));
    A2 = -rcarrayformat(rc2ar(Kftemp,Kbtemp),'format',3);
    
    nchannels = size(A2,1);
    pf = eye(nchannels);
    
    tstart = tic;
    out = pdc11(A2,pf,'metric',metric);
    telapsed(i) = toc(tstart);
    
end

%%
semilogy(channels, telapsed,'-s');
title('cpu time');
xlabel('channels');
ylabel('time (s)');