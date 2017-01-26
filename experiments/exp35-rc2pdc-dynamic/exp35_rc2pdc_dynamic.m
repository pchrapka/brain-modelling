%% exp35_rc2pdc_dynamic
% test conversion of reflection coefficients to dynamic partial directed coherence

nchannels = 4;
norder = 10;
order_est = norder;
lambda = 0.99;

nsamples = 500;
ntrials = 1;

%% set up vrc
vrc_type = 'vrc-cp-ch2-coupling2-rnd';
vrc_type_params = {}; % use default
vrc_gen = VARGenerator(vrc_type, nchannels, 'version', 1);
if ~vrc_gen.hasprocess
    vrc_gen.configure(vrc_type_params{:});
end
data_vrc = vrc_gen.generate('ntrials',ntrials);

vrc_data_file = loadfile(vrc_gen.get_file());

%% dynamic pdc
npoints = size(vrc_data_file.signal,2);
result = rc2pdc_dynamic(...
    vrc_data_file.true.Kf(1:npoints,:,:,:),...
    vrc_data_file.true.Kb(1:npoints,:,:,:),...
    'metric','euc');

%% plot dynamic pdc

figure;
plot_pdc_dynamic(result)

%% regular pdc
idx = 150;
result2 = rc2pdc(...
    squeeze(vrc_data_file.true.Kf(idx,:,:,:)),...
    squeeze(vrc_data_file.true.Kb(idx,:,:,:)));

%% plot regular pdc
flg_print = [1 0 0 0 0 0 0];
fs = 1;
w_max = fs/2;
ch_labels = [];
flg_color = 0;
flg_sigcolor = 1;

h=figure;
% set(h,'NumberTitle','off','MenuBar','none', 'Name', name )
xplot(result2,flg_print,fs,w_max,ch_labels,flg_color,flg_sigcolor);