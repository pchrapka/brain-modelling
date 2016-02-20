%% exp06_ar_lattice_test
%
%   Goal: Test how big my lattice can be without getting NaNs or exploding
%   signals
%
%   Results:
%   Kf = Kb = 0.082*ones
%       limit is order = 4, channels = 12

close all;

params = [];
params.nchannels = [13];%[5 10 11 12 13];
params.order = 4;
params.nsamples = 1000;

doplot = true;

for j=1:length(params.nchannels)
    order = params.order;
    nchannels = params.nchannels(j);
    nsamples = params.nsamples;
    
    resuls.nchannels_name(j) = {sprintf('%d channels',nchannels)};
    
    Kf = 0.082*ones(order, nchannels, nchannels);
    % NOTE a multiple of 0.1 is too big for the algo
    % NOTE this form tops out at 4th order and 12 channels
    Kb = Kf;

    [~,X,noise] = gen_stationary_ar_lattice(Kf,Kb,nsamples);

    if doplot
        rows = ceil(sqrt(nchannels));
        cols = ceil(nchannels/rows);
        % plot channels
        figure;
        for ch=1:nchannels
            subaxis(rows, cols, ch,...
                'Spacing', 0, 'SpacingVert', 0.05, 'Padding', 0, 'Margin', 0.05);
            plot(X(ch,:));
            
            if ch == 1
                title(sprintf('channels %d',nchannels));
            end
            ylabel(sprintf('%d',ch));
            set(gca,'xticklabel',[]);
        end
    end
    
end