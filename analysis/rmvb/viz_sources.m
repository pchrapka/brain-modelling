% viz_sources

figure;
cfgplot_scatter = [];
cfgplot_scatter.method = 'all';
pipeline.steps{end}.plot_source_time('scatter', cfgplot_scatter);

%%

figure;
pipeline.steps{end}.plot_anatomical_time('funparameter','pow');

%%
figure;
pipeline.steps{end}.plot_anatomical();

%%
cfgplot = [];
cfgplot.nslices = 20;
cfgplot.slicerange = [160 256]; % has 256 slices to choose from
pipeline.steps{end}.plot_anatomical('log', false, 'options', cfgplot);

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