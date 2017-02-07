function plot_trials(data)

[nchannels,nsamples,ntrials] = size(data);
    
trial = 1;
figure;

while true
    
    for i=1:nchannels
        subplot(nchannels,1,i);
        plot(squeeze(data(i,:,trial)));
        xlim([1 nsamples]);
        
        if i==1
            title(sprintf('trial %d',trial));
        end
    end
    fprintf('variance\n');
    var_data = var(squeeze(data(:,:,trial)),0,2);
    disp(var_data);
    
    reply = input('any key for next trial, q to quit:','s');
    switch reply
        case {'Q','q'}
            break;
    end
    
    trial = trial + 1;
    if trial > ntrials
        break;
    end
    
end

end