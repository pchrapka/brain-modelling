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

doplot = false;

for j=1:length(params.nchannels)
    order = params.order;
    nchannels = params.nchannels(j);
    nsamples = params.nsamples;
    
    resuls.nchannels_name(j) = {sprintf('%d channels',nchannels)};
    
    Kf = 0.082*ones(order, nchannels, nchannels);
    % NOTE a multiple of 0.1 is too big for the algo
    % NOTE this form tops out at 4th order and 12 channels
    % NOTE "If the eigenvalues of $A_{1}$ have modulus less than 1, the sequence
    % $A^{i}_1, i=0,1,... $ is absolutely summable" Lutkepohl2005, p.13
    % If `Kf = 0.082*ones(4,13,13)`, then one eigenvalue exceeds 1. That is
    % my problem.
    % For VAR(p), p > 1, (2.1.9) or (2.1.12) on p.15 is more appropriate
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