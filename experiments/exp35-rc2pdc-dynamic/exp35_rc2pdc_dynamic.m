%% exp35_rc2pdc_dynamic
% test conversion of reflection coefficients to dynamic partial directed coherence

nchannels = 4;
norder = 10;
order_est = norder;
lambda = 0.99;

nsamples = 2000;
ntrials = 1;

nsims = 1;
nsims_generate = 2;

%% set up vrc
vrc_type = 'vrc-coupling0-fixed';
vrc_type_params = {'nsamples',nsamples};
vrc_gen = VARGenerator(vrc_type, nchannels, 'version', 1);
if ~vrc_gen.hasprocess
    vrc_gen.configure(vrc_type_params{:});
end
data_vrc = vrc_gen.generate('ntrials',nsims_generate*ntrials);

vrc_data_file = loadfile(vrc_gen.get_file());

%% dynamic pdc

result = rc2pdc_dynamic(vrc_data_file.true.Kf,vrc_data_file.true.Kb,...
    'metric','euc');

%% plot dynamic pdc

plot_pdc_dynamic(result)