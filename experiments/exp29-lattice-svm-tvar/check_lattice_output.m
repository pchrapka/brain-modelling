%% load data
% data_bench = loadfile('/home/chrapkpk/Documents/projects/brain-modelling/experiments/exp29-lattice-svm-tvar/mtsparse2gamma/output/vrc-cp-ch2-coupling2-rnd-c13-v1-s1-MCMTLOCCD_TWL2-T5-C13-P8-lambda=0.98-gamma=24.40.mat');
data_bench = loadfile('/home/chrapkpk/Documents/projects/brain-modelling/experiments/exp29-lattice-svm-tvar/mtsparse2gamma/output/vrc-cp-ch2-coupling2-rnd-c13-v1-s1-MCMTLOCCD_TWL2-T5-C13-P8-lambda=0.98-gamma=32.20.mat');
data_pipe_lf = loadfile('/home/chrapkpk/Documents/projects/brain-modelling/analysis/lattice-svm/output/params_sd_tvar_p8_ch13/al-std/lf-MCMTLOCCDTWL2-mt5-p10-l099-g28/lattice-filtered-id1.mat');
data_pipe_al = loadfile('/home/chrapkpk/Documents/projects/brain-modelling/analysis/lattice-svm/output/params_sd_tvar_p8_ch13/al-std/labeled-id1.mat');
data_vrc = loadfile('/home/chrapkpk/Documents/projects/brain-modelling/experiments/output-common/simulated/vrc-cp-ch2-coupling2-rnd-c13-v1.mat');

%% check estimates

mode = 'image-order';
figure('name','estimate pipeline');
plot_rc(data_pipe_lf,'mode',mode);
% the problem is here?
% -> input data?
% -> order?

figure('name','estimate benchamrk');
data_bench2 = [];
data_bench2.Kf = data_bench.estimate;
plot_rc(data_bench2,'mode',mode);

figure('name','true');
data_vrc2 = [];
data_vrc2.Kf = data_vrc.true;
plot_rc(data_vrc2,'mode',mode);

%% check time series

nchannels = size(data_vrc.signal,1);
for i=1:nchannels
    estimate = data_vrc.signal(i,:,1);
    target = data_pipe_al.avg.mom{i};
    data_mse = mse(estimate(:),target(:));
    fprintf('mse for channel %d: %g\n',i,data_mse);
end

%% check normalized time series

data_al_norm = normalizev(bf_get_sources(data_pipe_al));
nchannels = size(data_vrc.signal_norm,1);
for i=1:nchannels
    estimate = data_vrc.signal_norm(i,:,1);
    target = data_al_norm(i,:);
    data_mse = mse(estimate(:),target(:));
    fprintf('mse for channel %d: %g\n',i,data_mse);
end