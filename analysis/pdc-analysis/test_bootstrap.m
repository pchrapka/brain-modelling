%% test_bootstrap

% lf_file = '/home-new/chrapkpk/Documents/projects/brain-modelling/analysis/pdc-analysis/output/std-s03-10/aal-coarse-19-outer-nocer-plus2/lf-sources-ch12-trials100-samplesall-normallchannels-envno/MCMTLOCCD_TWL4-T60-C12-P3-lambda=0.9900-gamma=1.000e-03.mat';

nchannels = 12;
norder = 3;
order_est = norder;
lambda = 0.99;
gamma = 1;

nsamples = 3000;
ntrials = 40;

%% set up vrc
vrc_type = 'vrc-cp-ch2-coupling2-rnd';
vrc_type_params = {'time',nsamples,'order',norder}; % use default
vrc_gen = VARGenerator(vrc_type, nchannels, 'version', 2);
if ~vrc_gen.hasprocess
    vrc_gen.configure(vrc_type_params{:});
end
data_vrc = vrc_gen.generate('ntrials',ntrials);

check_data = true;
if check_data
    figure;
    for i=1:ntrials
        hold off
        plot(data_vrc.signal(:,:,i)');
        
        prompt = 'hit any key to continue, q to quit';
        resp = input(prompt,'s');
        if isequal(lower(resp),'q')
            break;
        end
    end
end

% vrc_data = loadfile(vrc_gen.get_file());
vrc_data_file = vrc_gen.get_file();

%% set up data
[~,exp_name,~] = fileparts(vrc_data_file);
outdir = 'output';

file_data = fullfile(outdir,exp_name,'source_data.mat');
if ~exist(file_data,'file')
    vrc_data = loadfile(vrc_data_file);
    save_parfor(file_data, vrc_data.signal);
end

%% set up filter

filters{1} = MCMTLOCCD_TWL4(nchannels,norder,ntrials,...
    'lambda',lambda,'gamma',gamma);

% filter results are dependent on all input file parameters

lf_files = run_lattice_filter(...
    file_data,...
    'basedir',outdir,...
    'outdir',exp_name,... 
    'filters', filters,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'force',false,...
    'verbosity',0,...
    'tracefields',{'Kf','Kb','ferror'},...
    'plot_pdc', false);

%% pdc_bootstrap

% select pdc params
pdc_params = {'downsample',4,'metric','diag'};

pdc_bootstrap(lf_files{1},'nresamples',1,'alpha',0.05,'pdc_params',pdc_params);
