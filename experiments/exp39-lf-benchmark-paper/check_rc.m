data_dir = '/home/phil/projects/brain-modelling/experiments/exp39-lf-benchmark-paper/output/vrc-stationary-trial5-nowarmup/vrc-full-coupling-rnd-c10-vexp39-sparsity0-05';
din = load(fullfile(data_dir,...
    ...'vrc-full-coupling-rnd-c10-vexp39-sparsity0-05-s1-MCMTLOCCD_TWL4-T5-C10-P8-lambda0.9900-gamma4.550e+00.mat'));
    ...'vrc-full-coupling-rnd-c10-vexp39-sparsity0-05-s1-NuttallStrandMT-T5-C10-P8.mat'));
    'vrc-full-coupling-rnd-c10-vexp39-sparsity0-05-s1-NuttallStrandMT-T5-C10-P8.mat'));

temp_true.coef = squeeze(din.data.truth(1,:,:,:));
temp_est.coef = squeeze(din.data.estimate(2000,:,:,:));

figure;
plot_rc_stationary(temp_true,'mode','image-order')
figure;
plot_rc_stationary(temp_est,'mode','image-order')