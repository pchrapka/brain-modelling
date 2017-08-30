% NOTE run this code within plot_seed function

temp = obj.pdc(:,:,:,freq_idx);
% temp = obj.pdc(:,6,:,freq_idx);

temp_sum = 0;
temp_count = 0;
nchannels1 = size(temp,2);
nchannels2 = size(temp,3);
for i=1:nchannels1
    for j=1:nchannels2
        if i==j
            continue;
        end
        temp_channel = temp(:,i,j,:);
        temp_sum = temp_sum + sum(temp_channel(:));
        temp_count = temp_count + nsamples*nfreqs_sel;
    end
end

temp_mean = temp_sum/temp_count;
fprintf('mean %g\n',temp_mean);
