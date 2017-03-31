function pdc_bootstrap_check_distr(file_pdc_sig, sample_idx, varargin)
p = inputParser();
addRequired(p,'file_pdc_sig',@ischar);
addRequired(p,'resample_idx',@isnumeric);
addParameter(p,'mode','all',@(x)any(validatestring(x,{'all','loop'})));
% addParameter(p,'eeg_file','',@ischar);
% addParameter(p,'leadfield_file','',@ischar);
% addParameter(p,'envelope',false,@islogical)
% addParameter(p,'patch_type','',@ischar);
parse(p,file_pdc_sig,sample_idx,varargin{:});

[workingdir,sig_filename,~] = fileparts(file_pdc_sig);
% filter_name = strrep(workingdir,'-bootstrap','');

% get tag between [pdc-dynamic-...-ds\d]-sig
pattern = '.*(pdc-dynamic-.*)-sig';
result = regexp(sig_filename,pattern,'tokens');
pdc_tag = result{1}{1};

pattern = '.*sig-n(\d+)-.*';
result = regexp(sig_filename,pattern,'tokens');
nresample = str2double(result{1}{1});

file_sample_name = sprintf('sample%d-n%d.mat',sample_idx,nresample);
file_sample = fullfile(workingdir,'bootstrap-by-samples',pdc_tag,file_sample_name);

data = loadfile(file_sample);
[~,nchannels,~,nfreq] = size(data);

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
    w = 0:(nfreq-1);
    w = w/nfreq*0.5;
    bins = [-inf bins inf];
    for row=1:nchannels
        for col=1:nchannels
            plot_idx = (row-1)*nchannels + col;
            subaxis(nchannels, nchannels, plot_idx,...
                'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.1);
            
            plot_data = zeros(length(bins),nfreq);
            for f=1:nfreq
                count = histc(squeeze(data(:,row,col,f)),bins);
                plot_data(:,f) = count';
            end
            
            imagesc(plot_data,clim);
            
            if col==1
                ylabel(sprintf('ch %d',row));
            end
            
            if row==nchannels
                xlabel(sprintf('ch %d',col));
            end
            
            if col==1 && row==nchannels
                xlabel({sprintf('ch %d',col),'freq'});
                % set x ticks
                ticks = [1 nfreq];
                labels = cell(size(ticks));
                for i=1:length(ticks)
                    labels{i} = sprintf('%0.1f',w(ticks(i)));
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
