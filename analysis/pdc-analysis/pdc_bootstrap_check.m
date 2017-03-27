function pdc_bootstrap_check(file_pdc_sig,file_trials)

[workingdir,~,~] = fileparts(file_pdc_sig);

% get original trial data
data_trials = loadfile(file_trials);

figure('Position',[1 1 1000 600]);
for i=1:nresamples
    % get resampled data
    resampledir = sprintf('resample%d',i);
    data_bootstrap_file = fullfile(workingdir, resampledir, sprintf('resample%d.mat',i));
    
    data_bs = loadfile(data_bootstrap_file);
    
    for j=1:ntrials
        hold off;
        % plot original 
        subplot(1,2,1);
        plot(data_trials(:,:,j)');
        title(resampledir);
        ylabel(sprintf('trial %d',j));
        
        subplot(1,2,2);
        plot(data_bs(:,:,j)');
        
        prompt = 'hit any key to continue, q to quit';
        resp = input(prompt,'s');
        if isequal(lower(resp),'q')
            break;
        end
    end


end