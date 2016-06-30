%% exp26_autospec
%
%   Goal:
%       explore relationship between AR and reflection coefficients, using
%       Automatic Spectra toolbox

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
    s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse);
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
m=1;
trace = {};
n=1;
data_coh = {};

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

data{k}.coef = shiftdim(rcb(:,:,2:end),2);
data{k}.name = 'RCB Burgv';
k = k+1;

% convert parcor to ar
[arest,~] = pc2arset(pc,R0);
data{k}.coef = shiftdim(arest(:,:,2:end),2);
data{k}.name = 'AR Burgv';
k = k+1;

%% convert to RC

% [AR,RC] = ar2arset_e(s.A);

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

% NOTE Does not match up with RC from Burgv function
% data{k}.coef = kest;
% data{k}.name = 'RC (ar2rc)';
% k = k+1;


%% estimate connectivity with Nuttall Strand
% 
% % prep data
% x = sources(:,:,1)';
% 
% % estimate
% method = 13;
% [AR,RC,PE] = tsa.mvar(x, norder, method);
% 
% % transform estimates into common data struct
% kest = zeros(norder, nchannels, nchannels);
% aest = zeros(norder, nchannels, nchannels);
% for i=1:norder
%     idx_start = (i-1)*nchannels+1;
%     idx_end = i*nchannels; 
%     aest(i,:,:) = AR(:,idx_start:idx_end);
%     kest(i,:,:) = RC(:,idx_start:idx_end);
% end
% % 
% data{k}.name = 'RC Nuttall Strand';
% data{k}.coef = kest;
% k = k+1;
% 
% data{k}.name = 'AR Nuttall Strand';
% data{k}.coef = aest;
% k = k+1;

%% convert to xspec function
nfreq = nsamples/2;
pxy = zeros(nchannels, nchannels, nfreq);

for i=1:nchannels
    for j=1:nchannels
        a = zeros(nchannels,1);
        b = a;
        a(i) = 1;
        b(j) = 1;
        
        [hab, fs] = pc2xspecv(pc,R0,a,b);
        pxy(i,j,:) = hab;
    end
end
pxy_time = shiftdim(shiftdim(pxy,-1),3);

trace{m}.name = 'PC PSD';
trace{m}.trace.Kf = abs(pxy_time);
m = m+1;

data_coh{n}.name = 'PC PSD';
data_coh{n}.coef = db(pxy,'power');
data_coh{n}.f = fs;
n = n+1;

% data{k}.name = 'PC PSD (Mean)';
% data{k}.coef = mean(shiftdim(abs(pxy),-1),4);
% k = k+1;
% 
% data{k}.name = 'PC PSD (Max)';
% data{k}.coef = max(shiftdim(abs(pxy),-1),[],4);
% k = k+1;


%% convert to coherence function
nfreq = nsamples/2;
cxy = zeros(nchannels, nchannels, nfreq);

for i=1:nchannels
    for j=1:nchannels
        a = zeros(nchannels,1);
        b = a;
        a(i) = 1;
        b(j) = 1;
        
        [fiab, fs] = pc2cohv(pc,R0,a,b);
        cxy(i,j,:) = fiab;
    end
end
cxy_time = shiftdim(shiftdim(cxy,-1),3);

trace{m}.name = 'PC Coh';
trace{m}.trace.Kf = abs(cxy_time);
m = m+1;

data_coh{n}.name = 'PC Coh';
data_coh{n}.coef = cxy;
data_coh{n}.f = fs;
n = n+1;

% data{k}.name = 'PC Coh (Mean)';
% data{k}.coef = mean(shiftdim(abs(cxy),-1),4);
% k = k+1;

%% estimate connectivity with mscohere
% nfreq = nsamples/2;
% nfreq = 257;
nfreq = 129;
cxy = zeros(nchannels, nchannels, nfreq);
for i=1:nchannels
    for j=1:nchannels
        cxy(i,j,:) = mscohere(sources(i,:,1), sources(j,:,1));
    end
end
cxy_time = shiftdim(shiftdim(cxy,-1),3);
trace{k}.name = 'mscohere';
trace{k}.trace.Kf = cxy_time;
k = k+1;

data_coh{n}.name = 'mscohere';
data_coh{n}.coef = cxy;
data_coh{n}.f = linspace(0,0.5,nfreq);
n = n+1;

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

%% plot traces
do_traces = false;
if do_traces
    for i=1:length(trace)
        %fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
        %figure('Name',fig_name,'NumberTitle','off')
        %plot_rc(trace{i}.trace,'mode',mode,'clim','none','abs',true,'threshold','none');
        
        fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
        figure('Name',fig_name,'NumberTitle','off')
        plot_rc(trace{i}.trace,'mode','image-order','clim',[0 1.5],'abs',true,'threshold',1.5);
        
    end
end

%% plot coh
do_coh = true;
if do_coh
    for i=1:length(data_coh)
        fig_name = sprintf('Trace %d: %s',i,data_coh{i}.name);
        figure('Name',fig_name,'NumberTitle','off')
        plot_coherence(data_coh{i});
    end
end

%% 
do_movie = false;
if do_movie
    i=1;
    
    fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
    figure('Name',fig_name,'NumberTitle','off')
    plot_rc(trace{i}.trace,'mode','movie-order','clim',[0 1.5],'abs',true,'threshold',1.5);
end