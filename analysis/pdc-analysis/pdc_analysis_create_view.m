function view_obj = pdc_analysis_create_view(pdc_file,eeg_file,leadfield_file,varargin)

p = inputParser();
addRequired(p,'pdc_file',@ischar);
% addRequired(p,'lf_file',@ischar);
addRequired(p,'eeg_file',@ischar);
addRequired(p,'leadfield_file',@ischar);
addParameter(p,'patch_type','aal',@ischar);
addParameter(p,'envelope',false,@islogical); % also none
addParameter(p,'significance',[],@ischar);
parse(p,pdc_file,eeg_file,leadfield_file,varargin{:});

%% set lattice options
lf = loadfile(leadfield_file);
patch_labels = lf.filter_label(lf.inside);
patch_labels = cellfun(@(x) strrep(x,'_',' '),...
    patch_labels,'UniformOutput',false);
% npatch_labels = length(patch_labels);
patch_centroids = lf.patch_centroid(lf.inside,:);
clear lf;

% nchannels = npatch_labels;

%% plot pdc params

% get fsample
eegdata = loadfile(eeg_file);
fsample = eegdata.fsample;
time = eegdata.time{1};
time = downsample(time,downsample_by);
clear eegdata;

%%  set up ViewPDC object
patch_info = ChannelInfo(patch_labels,...
    'coord', patch_centroids);
patch_info.populate(p.Results.patch_type);

view_obj = ViewPDC(pdc_file,...
    'fs',fsample,...
    'info',patch_info,...
    'time',time,...
    'outdir','data',...
    'w',[0 100]/fsample);

end