function pdc_bootstrap_check(file_pdc_sig,file_trials)

[workingdir,~,~] = fileparts(file_pdc_sig);

% get original trial data
data_trials = loadfile(file_trials); 
nresamples = 5;

figure('Position',[1 1 1500 600]);
for i=1:nresamples
    % get resampled data
    resampledir = sprintf('resample%d',i);
    data_bootstrap_file = fullfile(workingdir, resampledir, sprintf('resample%d.mat',i));
    
    data_bs = loadfile(data_bootstrap_file); 
    ntrials = size(data_bs,3);
    
    for j=1:ntrials
        hold off;
        % plot original 
        subplot(2,2,1);
        plot(data_trials(:,:,j)');
        ylabel('real');
        title(sprintf('trial %d',j));
        
        subplot(2,2,2);
        plot(data_bs(:,:,j)');
        ylabel(resampledir);
        
        subplot(2,2,3);
        [pxx,f] = pwelch(data_trials(1,:,j),[],[],[],2048);
        plot(f,pxx);
        xlim([0 100]);
        ylabel('channel 1 psd');
        
        subplot(2,2,4);
        [pxx,f] = pwelch(data_bs(1,:,j),[],[],[],2048/4);
        plot(f,pxx);
        xlim([0 100]);
        
        prompt = 'hit any key to continue, q to quit';
        resp = input(prompt,'s');
        if isequal(lower(resp),'q')
            break;
        end
    end


end