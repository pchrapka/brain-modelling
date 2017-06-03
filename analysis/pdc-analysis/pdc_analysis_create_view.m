function view_obj = pdc_analysis_create_view(file_sources_info,varargin)

p = inputParser();
addRequired(p,'file_sources_info',@ischar);
addParameter(p,'downsample',1,@isnumeric);
parse(p,file_sources_info,varargin{:});

data = loadfile(file_sources_info);
fsample = data.fsample/p.Results.downsample;
time = data.time;
time = downsample(time,p.Results.downsample);

%%  set up ViewPDC object
patch_info = ChannelInfo(data.labels,...
    'coord', data.centroids);
patch_info.populate(data.patch_type);

view_obj = ViewPDC(...
    'fs',fsample,...
    'info',patch_info,...
    'time',time,...
    'outdir','data',...
    'w',[0 100]/fsample);

end