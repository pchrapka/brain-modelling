%% exp32_plot_rc

data = loadfile('output/vrc-coupling0-fixed-c4-s1-BurgVector-C4-P10.mat');
% data = loadfile('output/vrc-coupling0-fixed-c4-s1-MCMTQRDLSL1-T5-C4-P10-lambda=0.98.mat');
% data = loadfile('output/vrc-coupling0-fixed-c4-s1-MLOCCD_TWL-C4-P10-lambda=0.98-gamma=7.45.mat');
% data = loadfile('output/vrc-coupling0-fixed-c4-s1-MQRDLSL1-C4-P10-lambda=0.98.mat');
% data = loadfile('output/vrc-coupling0-fixed-c4-s1-MQRDLSL2-C4-P10-lambda=0.98.mat');
data_orig = loadfile('../output-common/simulated/vrc-coupling0-fixed-c4.mat');

estimate = squeeze(data.estimate(end,:,:,:));
truth = squeeze(data_orig.true(1,:,:,:));

estimate2 = reshape(estimate,10,16);
truth2 = reshape(truth,10,16);

clim = [-1 1];
figure;

subplot(1,2,1);
imagesc(estimate2,clim);
colorbar
title('estimated');

subplot(1,2,2);
imagesc(truth2,clim);
colorbar
title('true');
