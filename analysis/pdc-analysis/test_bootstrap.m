%% test_bootstrap

% lf_file = '/home-new/chrapkpk/Documents/projects/brain-modelling/analysis/pdc-analysis/output/std-s03-10/aal-coarse-19-outer-nocer-plus2/lf-sources-ch12-trials100-samplesall-normallchannels-envno/MCMTLOCCD_TWL4-T60-C12-P3-lambda=0.9900-gamma=1.000e-03.mat';

nchannels = 12;
norder = 3;
order_est = norder;
lambda = 0.99;
gamma = 1;

process_version = 3;

switch process_version
    case 2
        nsamples = 3000;
        ntrials = 40;
        vrc_type_params = {'time',nsamples,'order',norder};
    case 3
        nsamples = 358;
        ntrials = 5;
        vrc_type_params = {};
end
    

%% set up vrc
vrc_type = 'vrc-cp-ch2-coupling2-rnd';
vrc_gen = VARGenerator(vrc_type, nchannels, 'version', process_version);
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
    'tracefields',{'Kf','Kb','Rf','ferror'},...
    'plot_pdc', false);

% select pdc params
downsample_by = 4;
pdc_params = {...
    'metric','diag',...
    'downsample',downsample_by,...
    };
pdc_files = rc2pdc_dynamic_from_lf_files(lf_files,'params',pdc_params);

%% pdc_bootstrap

pdc_sig_file = pdc_bootstrap(lf_files{1},'nresamples',10,'alpha',0.05,'pdc_params',pdc_params);
% temp = loadfile(pdc_sig_file);
% temp2 = [];
% temp2.pdc = temp;
% save_parfor(pdc_sig_file,temp2);

%% plot significance
view_sig_obj = ViewPDC(pdc_sig_file,'fs',1,'outdir','data','w',[0 0.5]);
directions = {'outgoing','incoming'};
for direc=1:length(directions)
    for ch=1:nchannels
        
        created = view_sig_obj.plot_seed(ch,...
            'direction',directions{direc},...
            'threshold_mode','numeric',...
            'threshold',0.01,...
            'vertlines',[0 0.5]);
        
        if created
            view_sig_obj.save_plot('save',true,'engine','matlab');
        end
        close(gcf);
    end
end

%%

params_plot_seed = {};
% params_plot_seed{1} = {'threshold',0.2};
params_plot_seed{1} = {'threshold_mode','significance'};
% params_plot_seed{2} = {'threshold_mode','significance_alpha'};

view_obj = ViewPDC(pdc_files{1},'fs',1,'outdir','data','w',[0 0.5]);
view_obj.pdc_sig_file = pdc_sig_file;
directions = {'outgoing','incoming'};
for direc=1:length(directions)
    for ch=1:nchannels
        for idx_param=1:length(params_plot_seed)
            params_plot_seed_cur = params_plot_seed{idx_param};
            
            created = view_obj.plot_seed(ch,...
                'direction',directions{direc},...
                params_plot_seed_cur{:},...
                'vertlines',[0 0.5]);
            
            if created
                view_obj.save_plot('save',true,'engine','matlab');
            end
            close(gcf);
        end
    end
end
