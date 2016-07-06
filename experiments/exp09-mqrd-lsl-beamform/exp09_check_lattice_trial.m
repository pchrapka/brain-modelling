%% exp09_check_lattice_trial

[srcdir,~,~] = fileparts(mfilename('fullpath'));
lattice_folder = fullfile(srcdir,'output','lattice');

trial = 1;
lattice_file = sprintf('lattice%d.mat',trial);
lattice = loadfile(fullfile(lattice_folder,lattice_file));
lattice.Kb = lattice.Kf;

%%
[nsamples,order,nchannels,~] = size(lattice.Kf);

for ch1=1:nchannels
    for ch2=ch1:nchannels
        figure;
        Kest_stationary = zeros(order,nchannels,nchannels);
        k_true = repmat(squeeze(Kest_stationary(:,ch1,ch2)),1,nsamples);
        plot_reflection_coefs(lattice, k_true, nsamples, ch1, ch2);
    end
end
