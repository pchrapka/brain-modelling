%% exp26_burgv
%
%   Goal:
%       explore different ways of applying burgv

trial_idx = 1:5;
ntrials = length(trial_idx);


%% get data

nchannels = 5;
nsamples = 400;
norder = 7;

s = VAR(nchannels,norder);
stable = false;

ncoefs = nchannels^2*norder;
sparsity = 0.1;
ncoefs_sparse = ceil(ncoefs*sparsity);
while ~stable
    s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse,'stable',true,'verbose',1);
    stable = s.coefs_stable(true);
    
    if stable
        sources = zeros(nchannels,nsamples,ntrials);
        [~,sources(:,:,1),~] = s.simulate(nsamples);
        
        h = figure;
        nrows = nchannels;
        ncols = 1;
        for i=1:nchannels
            subaxis(nrows, ncols, i,...
                'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
            
            plot(squeeze(sources(i,:,1)));
            set(gca,'xticklabel',[]);
            xlim([1 nsamples]);
            
            hold off;
        end
        
        prompt = 'Accept VRC? (y)';
        response = input(prompt,'s');
        switch response
            case 'y'
                close(h);
            otherwise
                stable = false;
        end
    end
    
end

% allocate mem for data
sources = zeros(nchannels,nsamples,ntrials);
for i=1:ntrials
    [~,sources(:,:,i),~] = s.simulate(nsamples);
end

figure;
nrows = nchannels;
ncols = 1;

for i=1:nchannels
    subaxis(nrows, ncols, i,...
        'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
    
    plot(squeeze(sources(i,:,1)));
    set(gca,'xticklabel',[]);
    xlim([1 nsamples]);
    
    hold off;
end

%% set up data
k=1;
data = {};

%% estimate model order

x = permute(sources(:,:,1),[1 3 2]);
Lmax = 20;
[pcsel,R0] = ARselv(x,Lmax);
fprintf('Estimated model order: %d\n', size(pcsel,3));

%% estimate coefs
[pc, R0] = burgv(x,norder);

data{k}.coef = shiftdim(pc(:,:,2:end),2);
data{k}.name = 'PC Burgv';
k = k+1;

% convert parcor to rc
[rcf,rcb,~,~] = pc2rcv(pc,R0);

data{k}.coef = shiftdim(rcf(:,:,2:end),2);
data{k}.name = 'RCF Burgv';
k = k+1;

% data{k}.coef = shiftdim(rcb(:,:,2:end),2);
% data{k}.name = 'RCB Burgv';
% k = k+1;

% convert parcor to ar
[arest,~] = pc2arset(pc,R0);
data{k}.coef = shiftdim(arest(:,:,2:end),2);
data{k}.name = 'AR Burgv';
k = k+1;

%% estimate coefs from avg signal
x = permute(mean(sources,3),[1 3 2]);
[pc, R0] = burgv(x,norder);

data{k}.coef = shiftdim(pc(:,:,2:end),2);
data{k}.name = 'PC Burgv Avg Signal';
k = k+1;

% convert parcor to rc
[rcf,rcb,~,~] = pc2rcv(pc,R0);

data{k}.coef = shiftdim(rcf(:,:,2:end),2);
data{k}.name = 'RCF Burgv Avg Signal';
k = k+1;

% data{k}.coef = shiftdim(rcb(:,:,2:end),2);
% data{k}.name = 'RCB Burgv Avg Signal';
% k = k+1;

% convert parcor to ar
[arest,~] = pc2arset(pc,R0);
data{k}.coef = shiftdim(arest(:,:,2:end),2);
data{k}.name = 'AR Burgv Avg Signal';
k = k+1;

%% estimate connectivity with Burgv average
pc_avg = zeros(size(pc));
R0_avg = zeros(size(R0));
for i=1:ntrials
    x = permute(sources(:,:,i),[1 3 2]);
    [pc, R0] = burgv(x,norder);
    pc_avg = pc_avg + pc;
    R0_avg = R0_avg + R0;
end
pc_avg = pc_avg/ntrials;
R0_avg = R0_avg/ntrials;

data{k}.coef = shiftdim(pc_avg(:,:,2:end),2);
data{k}.name = 'PC Burgv Avg';
k = k+1;

% convert parcor to rc
[rcf,rcb,~,~] = pc2rcv(pc_avg,R0_avg);

data{k}.coef = shiftdim(rcf(:,:,2:end),2);
data{k}.name = 'RCF Burgv Avg';
k = k+1;

% data{k}.coef = shiftdim(rcb(:,:,2:end),2);
% data{k}.name = 'RCB Burgv Avg';
% k = k+1;

% convert parcor to ar
[arest,~] = pc2arset(pc_avg,R0_avg);
data{k}.coef = shiftdim(arest(:,:,2:end),2);
data{k}.name = 'AR Burgv Avg';
k = k+1;

%% coefs with TSA toolbox

AR = zeros(nchannels,nchannels*norder);
for i=1:norder
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    AR(:,idx_start:idx_end) = s.A(:,:,i);
end
    
[AR,RC,PE] = tsa.ar2rc(AR);
% NOTE I'm pretty sure there's a bug in this function. It does not match up
% with RCF Burgv

% transform estimates into common data struct
kest = zeros(norder, nchannels, nchannels);
aest = zeros(norder, nchannels, nchannels);
for i=1:norder
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    aest(i,:,:) = AR(:,idx_start:idx_end);
    kest(i,:,:) = RC(:,idx_start:idx_end);
end

%% set up data structs

data{k}.coef = aest;
data{k}.name = 'AR (true)';
k = k+1;

%% plot the datas
do_data = true;
if do_data
    for i=1:length(data)
        
        %     fig_name = sprintf('Trace %d: %s (No thresh)',i,data{i}.name);
        %     figure('Name',fig_name,'NumberTitle','off')
        %     plot_rc_stationary(data{i},'mode','image-order','clim','none','abs',true,'threshold','none');
        %
        fig_name = sprintf('Trace %d: %s',i,data{i}.name);
        figure('Name',fig_name,'NumberTitle','off')
        plot_rc_stationary(data{i},'mode','image-order','clim',[0 1.5],'abs',true,'threshold',1.5);
        
%         fig_name = sprintf('Trace %d: %s (All)',i,data{i}.name);
%         figure('Name',fig_name,'NumberTitle','off')
%         plot_rc_stationary(data{i},'mode','image-all','clim',[0 1.5],'abs',true,'threshold',1.5);
        
        fig_name = sprintf('Trace %d: %s (Max)',i,data{i}.name);
        figure('Name',fig_name,'NumberTitle','off')
        plot_rc_stationary(data{i},'mode','image-max','clim','none','abs',true,'threshold','none');
    end
end
