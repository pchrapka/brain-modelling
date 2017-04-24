%% exp38_warmup_flipstate2

data_mode = 'concat';
% data_mode = 'seq';

%% set options
% nsims = 20;
nsims = 1;
nsims_benchmark = nsims;

ntrials = 5;

nchannels = 4;
order_est = 10;
lambda = 0.99;

verbosity = 0;

% data_type = 'vrc-coupling0-fixed';
% nsamples = 2000;
% data_params = {'nsamples', nsamples};

data_type = 'vrc-cp-ch2-coupling1-fixed';
data_params = {};

%% set up data

% load data
var_gen = VARGenerator(data_type, nchannels);
if ~var_gen.hasprocess
    var_gen.configure(data_params{:});
end
data_var = var_gen.generate('ntrials',nsims*ntrials);
nsamples = size(data_var.signal_norm,2);

%% set up filter options part 2
sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

%% set up data scenarios
params = [];
k=1;
nsections = 3;

params(k).sections = {'nothing','nothing','data'};
params(k).flipstate = false;
k= k+1;
params(k).sections = {'nothing','noise','data'};
params(k).flipstate = false;
k= k+1;
params(k).sections = {'noise','data','data'};
params(k).flipstate = false;
k= k+1;
params(k).sections = {'noise','flipdata','data'};
params(k).flipstate = false;
k= k+1;
params(k).sections = {'noise','flipdata','data'};
params(k).flipstate = true;

nparams = length(params);

outlabels = cell(nparams,1);
outfiles = cell(nparams,1);
for k=1:nparams
    outlabels{k} = [params(k).sections{:}];
    if params(k).flipstate
        outlabels{k} = [outlabels{k} sprintf('-flipstateyes')];
    else
        outlabels{k} = [outlabels{k} sprintf('-flipstateno')];
    end
    
    datafile = fullfile('output',data_type,sprintf('%s.mat',outlabels{k}));
    if ~exist(datafile,'file')
        data = {};
        % set up data
        for i=1:nsections
            switch params(k).sections{i}
                case 'nothing'
                    data{i} = {};
                case 'noise'
                    data{i} = gen_noise(nchannels, nsamples, ntrials);
                case 'flipdata'
                    data{i} = flipdim(data_var.signal_norm(:,:,1:ntrials),2);
                case 'data'
                    if i == nsections
                        data{i} = circshift(data_var.signal_norm(:,:,1:ntrials),[0 -1 0]);
                    else
                        data{i} = data_var.signal_norm(:,:,1:ntrials);
                    end
                otherwise
                    error('unknown section');
            end
        end
        
        save_parfor(datafile,data);
    else
        data = loadfile(datafile);
    end
    
    outfiles{k} = fullfile('output',data_type,...
        sprintf('filtered-%s-mode%s.mat',outlabels{k},data_mode));
    fresh = isfresh(outfiles{k},datafile);
    if fresh || ~exist(outfiles{k},'file')
        filter = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
        
        % run filter manually
        tracefields = {'Kf','Kb','Rf','ferror','berrord'};
        trace = LatticeTrace(filter,'fields',tracefields);
        
        switch data_mode
            case 'concat'
                data_concat = [];
                for i=1:nsections
                    if params(k).flipstate
                        warning('ignoring flip state');
                    end
                    if ~isempty(data{i})
                        if isempty(data_concat)
                            data_concat = data{i};
                        else
                            data_concat = cat(2,data_concat,data{i});
                        end
                    end
                end
                trace.run(data_concat,'verbosity',0,'mode','none');
                
            case 'seq'
                for i=1:nsections
                    if i==3 && params(k).flipstate
                        trace.flipstate();
                    end
                    if ~isempty(data{i})
                        trace.run(data{i},'verbosity',0,'mode','none');
                    end
                end
            otherwise
                error('unknown mode %s',data_mode);
        end
        
        % save data
        out = [];
        out.filter = trace.filter;
        for i=1:length(tracefields)
            field = tracefields{i};
            out.estimate.(field) = trace.trace.(field);
        end
        save_parfor(outfiles{k},out);
    end
    
    % view errors
    view_obj = ViewLatticeFilter(outfiles{k},'labels',outlabels{k});
    view_obj.compute({'ewaic','normtime'});
    view_obj.plot_criteria_vs_order_vs_time(...
        'criteria','normtime',...
        'orders',6:10);
    
    save_fig2('path',fullfile('output',data_type),'tag',[outlabels{k} '-normtime'],'save_flag',true,'formats',{'png'});
    close(gcf);
    
    view_obj.plot_criteria_vs_order_vs_time(...
        'criteria','ewaic',...
        'orders',6:10);
    
    save_fig2('path',fullfile('output',data_type),'tag',[outlabels{k} '-ewaic'],'save_flag',true,'formats',{'png'});
    close(gcf);
end

%% view all
view_obj = ViewLatticeFilter(outfiles,'labels',outlabels);
view_obj.compute({'ewaic','normtime','whitetime'});
view_obj.plot_criteria_vs_order_vs_time(...
    'criteria','normtime',...
    'file_list',1:nparams,...
    'orders',10);

save_fig2('path',fullfile('output',data_type),'tag','all-normtime','save_flag',true,'formats',{'png'});
close(gcf);

view_obj.plot_criteria_vs_order_vs_time(...
    'criteria','ewaic',...
    'file_list',1:nparams,...
    'orders',10);

save_fig2('path',fullfile('output',data_type),'tag','all-ewaic','save_flag',true,'formats',{'png'});
close(gcf);

view_obj.plot_criteria_vs_order_vs_time(...
    'criteria','whitetime',...
    'file_list',1:nparams,...
    'orders',10);

save_fig2('path',fullfile('output',data_type),'tag','all-whitetime','save_flag',true,'formats',{'png'});
close(gcf);

%% 
% data = loadfile('/home/phil/projects/brain-modelling/experiments/exp38-warmup-flipstate/output/vrc-coupling0-fixed/filtered-noiseflipdatadata-flipstateyes.mat');
% temp.Kf = data.estimate.Kf(1:2,:,:,:);
% figure;
% plot_rc(temp,'mode','image-order-summary');
% 
% temp.Kf = data.estimate.Kb(1:2,:,:,:);
% figure;
% plot_rc(temp,'mode','image-order-summary');
% 
% temp.Kf = data.estimate.Kf(1500:1501,:,:,:);
% figure;
% plot_rc(temp,'mode','image-order-summary');
% 
% temp.Kf = data.estimate.Kb(1500:1501,:,:,:);
% figure;
% plot_rc(temp,'mode','image-order-summary');

