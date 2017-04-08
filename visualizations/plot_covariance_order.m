function plot_covariance_order(data)
% data [iterations channels, order]

[nsamples, nchannels, norder] = size(data);
nplots = norder;
nrows = ceil(sqrt(nplots));
ncols = nrows;

count = 1;
for i=1:nrows
    for j=1:ncols
        if count <= norder
            subplot(nrows,ncols,count);
            imagesc(abs(cov(data(:,:,count))));
            colorbar;
            title(sprintf('order %d',count-1));
            count = count + 1;
        end
    end
end

end