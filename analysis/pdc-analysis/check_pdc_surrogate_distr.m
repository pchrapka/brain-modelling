function check_pdc_surrogate_distr(file_pdc_sig, sample_idx, varargin)
p = inputParser();
addRequired(p,'file_pdc_sig',@ischar);
addRequired(p,'resample_idx',@isnumeric);
addParameter(p,'mode','all',@(x)any(validatestring(x,{'all','loop'})));
addParameter(p,'w_range',[],@(x) (length(x) == 2) && isnumeric(x));
% addParameter(p,'eeg_file','',@ischar);
% addParameter(p,'leadfield_file','',@ischar);
% addParameter(p,'envelope',false,@islogical)
% addParameter(p,'patch_type','',@ischar);
parse(p,file_pdc_sig,sample_idx,varargin{:});

[workingdir,sig_filename,~] = fileparts(file_pdc_sig);
% filter_name = strrep(workingdir,'-surrogate','');

% get tag between [pdc-dynamic-...-ds\d]-sig
pattern = '.*(pdc-dynamic-.*)-sig';
result = regexp(sig_filename,pattern,'tokens');
pdc_tag = result{1}{1};

pattern = '.*sig-n(\d+)-.*';
result = regexp(sig_filename,pattern,'tokens');
nresample = str2double(result{1}{1});

pattern = '.*-alpha([\.\d]+).*';
result = regexp(sig_filename,pattern,'tokens');
alpha = str2double(result{1}{1});

file_sample_name = sprintf('sample%d-n%d.mat',sample_idx,nresample);
file_sample = fullfile(workingdir,'surrogate-by-samples',pdc_tag,file_sample_name);

data = loadfile(file_sample);
[~,nchannels,~,nfreq] = size(data);

w = 0:(nfreq-1);
w = w/nfreq*0.5;
if isempty(p.Results.w_range)
    w_range = [0 0.5];
else
    w_range = p.Results.w_range;
end

bins = 1:19;
bins = bins/20;

figure;

if isequal(p.Results.mode,'loop')
    for f=1:nfreq
        clf;
        for row=1:nchannels
            for col=1:nchannels
                plot_idx = (row-1)*nchannels + col;
                subaxis(nchannels, nchannels, plot_idx,...
                    'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.1);
                hist(squeeze(data(:,row,col,f)),bins);
                ylim([0 nresample]);
                
                if col == 1 && row == 1
                    title(sprintf('freq normalized (0-0.5) %0.4f',(f-1)/nfreq*0.5));
                end
                
                if col==1
                    ylabel(sprintf('ch %d',row));
                end
                
                if row==nchannels
                    xlabel(sprintf('ch %d',col));
                end
                
                if col ~= 1
                    set(gca,'YTick',[]);
                    set(gca,'YTickLabel',[]);
                end
                
                if row ~= nchannels
                    set(gca,'XTick',[]);
                    set(gca,'XTickLabel',[]);
                end
                
                
            end
        end
        
        prompt = 'hit any key to continue,\nn for next channel combination\nq to quit';
        resp = input(prompt,'s');
        switch lower(resp)
            case 'q'
                return;
            case 'n'
                break;
            otherwise
        end
    end
elseif isequal(p.Results.mode,'all')
    
    clim = [0 nresample];
    w_select = (w >= w_range(1)) & (w <= w_range(2));
    f_idx = 1:nfreq;
    f_idx = f_idx(w_select);
    
    bins = [-inf bins inf];
    for row=1:nchannels
        for col=1:nchannels
            plot_idx = (row-1)*nchannels + col;
            subaxis(nchannels, nchannels, plot_idx,...
                'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.1);
            
            plot_data = zeros(length(bins),length(f_idx));
            for k=1:length(f_idx)
                f = f_idx(k);
                count = histc(squeeze(data(:,row,col,f)),bins);
                plot_data(:,k) = count;
            end
            
            %imagesc(plot_data,clim);
            imagesc(plot_data);
            
            for k=1:length(f_idx)
                f = f_idx(k);
                pct = (1-alpha)*100;
                sig_val = prctile(squeeze(data(:,row,col,f)),pct,1);
                x = [k-0.5 k+0.5];
                y_val = find(histc(sig_val,bins) > 0,1,'first');
                y = y_val*ones(1,2);
                line(x,y,'LineWidth',2,'Color',[1 1 1]);
            end
            
            if col==1
                ylabel(sprintf('ch %d',row));
            end
            
            if row==nchannels
                xlabel(sprintf('ch %d',col));
            end
            
            if col==1 && row==nchannels
                xlabel({sprintf('ch %d',col),'freq'});
                % set x ticks
                ticks = [1 length(f_idx)];
                if ticks(2) == 1
                    ticks(2) = [];
                end
                labels = cell(size(ticks));
                for i=1:length(ticks)
                    w_idx = f_idx(ticks(i));
                    labels{i} = sprintf('%0.1f',w(w_idx));
                end
                set(gca,'XTick', ticks);
                set(gca,'XTickLabel',labels);
                
                ylabel({sprintf('ch %d',row),'pdc'});
                % set y ticks
                ticks = [1 length(bins)];
                set(gca,'YTick', ticks);
                set(gca,'YTickLabel', {'0','1'});
            else
                set(gca,'YTick',[]);
                set(gca,'YTickLabel',[]);
                
                set(gca,'XTick',[]);
                set(gca,'XTickLabel',[]);
            end
            
        end
    end
    colorbar;
end

end
