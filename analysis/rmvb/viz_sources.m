% viz_sources

%%
figure;
pipeline.steps{end}.plot_anatomical();

%%
pipeline.steps{end}.plot_anatomical('log', true);

%%
figure;
pipeline.steps{end}.plot_moment('2d-all')

%%
figure;
cfgplot_scatter = [];
cfgplot_scatter.method = 'all';
pipeline.steps{end}.plot_scatter(cfgplot_scatter)

%%

source = ftb.util.loadvar(pipeline.steps{6}.sourceanalysis);

%%
figure;
k = 1;
subplot(2,1,k);
plot(source.avg.pow);
k = k+1;

subplot(2,1,k);
plot(log(source.avg.pow));

%%

[~,idx_max] = max(source.avg.pow);
figure;
source_signal = sqrt(sum(source.avg.mom{idx_max}.^2));
plot(source.time, source_signal);

%%
figure;
k = 1;

subplot(3,1,k);
plot(source.time, source.avg.mom{idx_max}(k,:));
k = k+1;

subplot(3,1,k);
plot(source.time, source.avg.mom{idx_max}(k,:));
k = k+1;

subplot(3,1,k);
plot(source.time, source.avg.mom{idx_max}(k,:));
k = k+1;