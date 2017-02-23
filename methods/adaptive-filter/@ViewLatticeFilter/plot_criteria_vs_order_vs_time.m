function plot_criteria_vs_order_vs_time(obj,varargin)
%PLOT_ESTERROR_VS_ORDER_VS_TIME plots filter order vs estim. error vs time
%   PLOT_ESTERROR_VS_ORDER_VS_TIME(...) plots filter order vs estimation
%   error vs time
%
%   Parameters
%   -----
%   orders (vector)
%       list of orders to use in plot

p = inputParser();
addParameter(p,'criteria','aic',@(x) any(validatestring(x,{'aic','sc'})));
addParameter(p,'orders',[],@isvector);
% addParameter(p,'params',{},@iscell);
parse(p,varargin{:});

obj.load();

% get dimensions
dims = size(obj.data.estimate.ferror);
norderp1 = dims(end);
nsamples = dims(1);
switch length(dims)
    case 4
        ntrials = dims(3);
        nchannels = dims(2);
    case 3
        ntrials = 1;
        nchannels = dims(2);
end

% set default orders
if isempty(p.Results.orders)
    order_list = 1:norderp1-1;
else
    order_list = p.Results.orders;
end
norders = length(order_list);
order_max = max(order_list);

if order_max > norderp1-1
    error('not enough orders in data (%d), requested (%d)',norderp1-1,order_max);
end

% allocate mem
cb = zeros(nsamples,norders);
cf = zeros(nsamples,norders);

legend_str = cell(norders,1);
for i=1:norders
    delta = 0.01;
    Vfprev = delta*eye(nchannels,nchannels);
    Vbprev = delta*eye(nchannels,nchannels);
    
    for j=1:nsamples
        
        order = order_list(i);
        idx = order+1;
        
        switch length(dims)
            case 4
                ferror = obj.data.estimate.ferror(j,:,:,idx);
                berror = obj.data.estimate.berrord(j,:,:,idx);
            case 3
                ferror = obj.data.estimate.ferror(j,:,idx);
                berror = obj.data.estimate.berrord(j,:,idx);
            otherwise
                error('uh oh\n');
        end
        ferror = squeeze(ferror);
        berror = squeeze(berror);
        
        %Taylor, James W. "Exponentially weighted information criteria for
        %selecting among forecasting models." International Journal of
        %Forecasting 24.3 (2008): 513-524.
       
        Vf = obj.data.filter.lambda*Vfprev + ferror*ferror';
        Vb = obj.data.filter.lambda*Vbprev + berror*berror';
        
        switch p.Results.criteria
            case 'aic'
                % Akaike
                n = j*ntrials;
                g = 2*order*nchannels^2/n;
            case 'sc'
                % Bayesian Schwartz
                n = j*ntrials;
                g = log(n)*order*nchannels^2/n;
        end
        

        cf(j,i) = log((1-lambda)/(1-lambda^j)) + logdet(Vf) + g;
        cb(j,i) = log((1-lambda)/(1-lambda^j)) + logdet(Vb) + g;
        
        Vfprev = Vf;
        Vbprev = Vb;
    end
    
    legend_str{i} = sprintf('%d',order);
end

[~,name,~] = fileparts(obj.file);
name = strrep(name,'-',' ');
name = strrep(name,'_','-');
screen_size = get(0,'ScreenSize');
figure('Position',screen_size,'Name',name);
colors = get_colors(norders,'jet');

nrows = 2;
ncols = 2;
plot_idx = 0;
for i=1:nrows
    for j=1:ncols
        plot_idx = plot_idx + 1;
        subplot(nrows,ncols,plot_idx);
        hold on;
        
        title_str = {};
        switch i
            case 1
                data = cf;
                title_str{1} = sprintf('Forward IC - %s',upper(p.Results.criteria));
                ylabel_str = 'IC';
            case 2
                data = cb;
                title_str{1} = sprintf('Backward IC - %s',upper(p.Results.criteria));
                ylabel_str = 'IC';
        end
        
        if j==1
            % plot IC vs samples
            h = zeros(norders,1);
            for k=1:norders
                h(k) = plot(1:nsamples,data(:,k),'-o','Color',colors(k,:),'MarkerSize',2);
                %h(i) = scatter(1:nsamples,ferrors(:,k),2,colors(k,:),'filled');
            end
            
            xlabel('Sample');
        end
        
        if j==2
            % plot last IC vs order
            plot(order_list,data(nsamples,:),'-o');
            
            xlabel('Order');
            title_str{2} = sprintf('sample %d',nsamples);
        end
        
        % add labels
        ylabel(ylabel_str);
        
        % add legned
        if i==1 && j==1
            legend(h,legend_str);
        end
        
        if ~isempty(title_str)
            title(title_str);
        end
        
    end
end

end

function out = logdet(A)
L = chol(A);
out = 2*sum(log(diag(L)));
end