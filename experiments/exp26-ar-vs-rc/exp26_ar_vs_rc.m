%% exp26_ar_vs_rc
%
%   Goal:
%       explore relationship between AR and reflection coefficients

trial_idx = 1:5;
ntrials = length(trial_idx);


%% get data

nchannels = 5;
nsamples = 400;
norder = 4;

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

%% convert to RC

AR = zeros(nchannels,nchannels*norder);
for i=1:norder
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    AR(:,idx_start:idx_end) = s.A(:,:,i);
end
    
[AR,RC,PE] = tsa.ar2rc(AR);

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
k=1;
data = {};

data{k}.coef = aest;
data{k}.name = 'AR';
k = k+1;

data{k}.coef = kest;
data{k}.name = 'RC';
k = k+1;

%% estimate connectivity with Nuttall Strand

% prep data
x = sources(:,:,1)';

% estimate
method = 13;
[AR,RC,PE] = tsa.mvar(x, norder, method);

% transform estimates into common data struct
kest = zeros(norder, nchannels, nchannels);
aest = zeros(norder, nchannels, nchannels);
for i=1:norder
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    aest(i,:,:) = AR(:,idx_start:idx_end);
    kest(i,:,:) = RC(:,idx_start:idx_end);
end

data{k}.name = 'RC Nuttall Strand';
data{k}.coef = kest;
k = k+1;

data{k}.name = 'AR Nuttall Strand';
data{k}.coef = aest;
k = k+1;


%% plot the datas
for i=1:length(data)
    
    fig_name = sprintf('Trace %d: %s (No thresh)',i,data{i}.name);
    figure('Name',fig_name,'NumberTitle','off')
    plot_rc_stationary(data{i},'mode','image-order','clim','none','abs',true,'threshold','none');
    
    fig_name = sprintf('Trace %d: %s',i,data{i}.name);
    figure('Name',fig_name,'NumberTitle','off')
    plot_rc_stationary(data{i},'mode','image-order','clim',[0 1.5],'abs',true,'threshold',1.5);
    
    fig_name = sprintf('Trace %d: %s (Max)',i,data{i}.name);
    figure('Name',fig_name,'NumberTitle','off')
    plot_rc_stationary(data{i},'mode','image-max','clim','none','abs',true,'threshold','none');
end

%% old code
% %% estimate connectivity with Nuttall Strand
% 
% % prep data
% x = sources(:,:,1)';
% 
% % estimate
% method = 13;
% [AR,RC,PE] = tsa.mvar(x, order_est, method);
% 
% % transform estimates into common data struct
% kest = zeros(order_est, nchannels, nchannels);
% aest = zeros(order_est, nchannels, nchannels);
% for i=1:order_est
%     idx_start = (i-1)*nchannels+1;
%     idx_end = i*nchannels; 
%     aest(i,:,:) = AR(:,idx_start:idx_end);
%     kest(i,:,:) = RC(:,idx_start:idx_end);
% end
% kest_time = repmat(kest,1,1,1,nsamples);
% kest_time = shiftdim(kest_time,3);
% data{k}.name = 'Nuttall Strand';
% data{k}.coef = kest_time;
% k = k+1;
% 
% aest_time = repmat(aest,1,1,1,nsamples);
% aest_time = shiftdim(aest_time,3);
% data{k}.name = 'Nuttall Strand AR';
% data{k}.coef = aest_time;
% k = k+1;
% 
% %% estimate connectivity with mscohere
% nfreq = 129;
% cxy = zeros(nchannels, nchannels, nfreq);
% for i=1:nchannels
%     for j=1:nchannels
%         cxy(i,j,:) = mscohere(sources(i,:,1), sources(j,:,1),[]);
%     end
% end
% cxy = shiftdim(cxy,-1);
% cxy_time = shiftdim(cxy,3);
% data{k}.name = 'Coherence';
% data{k}.coef = cxy_time;
% k = k+1;
% 
% %% plot traces
% mode = 'image-order';
% for i=1:length(trace)
%     
%     switch mode
%         case 'image-order'
%             %fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
%             %figure('Name',fig_name,'NumberTitle','off')
%             %plot_rc(trace{i}.trace,'mode',mode,'clim','none','abs',true,'threshold','none');
%             
%             fig_name = sprintf('Trace %d: %s',i,data{i}.name);
%             figure('Name',fig_name,'NumberTitle','off')
%             plot_rc_stationary(data{i},'mode',mode,'clim',[0 1.5],'abs',true,'threshold',1.5);
%     end
% end
% 
% %% movie
% do_movie = true;
% 
% if do_movie
%     %i = 1;
%     %i = 4; % mt5
%     %i = 5; % sparse
%     %i = 7; % mqrdlsl noise warmup
%     %i = 8; % mt5 noise warmup
%     %i = 9; % nuttall strand
%     i = 10; % nuttall strand AR
%     %i = 11; % coherence
%     fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
%     figure('Name',fig_name,'NumberTitle','off')
%     plot_rc(trace{i}.trace,'mode','movie-order','clim',[0 1.5],'abs',true,'threshold',1.5);
% end

