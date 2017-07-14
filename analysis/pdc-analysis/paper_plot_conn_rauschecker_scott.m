%% paper_plot_conn_rauschecker_scott

patch_type = 'aal-coarse-19';
% patch_type = 'default';
labels = {'Prefrontal','Motor','Parietal','Auditory','Temporal','Occipital','V1'};
hemi = {'Left','Left','Left','Left','Left','Left','Left'};
nchannels = length(labels);

% from -> to
connections = {...
    {'Motor','Parietal'},...
    {'Motor','Prefrontal'},...
    {'Prefrontal','Motor'},...
    {'Prefrontal','Parietal'},...
    {'Parietal','Motor'},...
    {'Parietal','Temporal'},...
    {'Auditory','Temporal'},...
    {'Auditory','Prefrontal'},...
    {'Temporal','Parietal'},...
    {'Temporal','Motor'},...
    {'Temporal','Prefrontal'},...
    {'V1','Temporal'},...
    {'Occipital','Temporal'},...
    };


data = [];
data.pdc = zeros(1,nchannels,nchannels,1);
data.nfreqs = 1;
for i=1:length(connections)
    % convert connections to indices
    pair = connections{i};
    idx_from = find(lumberjack.strfindlisti(labels,pair{1}),1,'first');
    idx_to = find(lumberjack.strfindlisti(labels,pair{2}),1,'first');
    
    % set pdc
    data.pdc(1,idx_to,idx_from,1) = 1;
end

% create pdc file

file_pdc = fullfile('output','conn-rauschecker-scott.mat');
save_parfor(file_pdc,data);

%%  set up ViewPDC object
patch_info = ChannelInfo(labels); %,'region',labels,'hemisphere',hemi);
patch_info.populate(patch_type);

view_obj = ViewPDC(...
    'info',patch_info,...
    'outdir','data');

view_obj.file_pdc = {file_pdc};

%%

view_obj.plot_connectivity_matrix();
cmap = colormap('gray');
cmap = flipdim(cmap,1);
colormap(cmap);
% colorbar('hide');

view_obj.save_plot('save',true,'engine','matlab');