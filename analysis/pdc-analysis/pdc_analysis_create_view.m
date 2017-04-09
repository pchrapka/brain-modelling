function view_obj = pdc_analysis_create_view(pdc_file,sources_data_file,varargin)

p = inputParser();
addRequired(p,'pdc_file',@ischar);
addRequired(p,'sources_data_file',@ischar);
addParameter(p,'downsample',1,@isnumeric);
parse(p,pdc_file,sources_data_file,varargin{:});

data = loadfile(sources_data_file);
fsample = data.fsample/p.Results.downsample;
time = data.time;
time = downsample(time,p.Results.downsample);

%%  set up ViewPDC object
patch_info = ChannelInfo(data.labels,...
    'coord', data.centroids);
patch_info.populate(data.patch_type);

view_obj = ViewPDC(pdc_file,...
    'fs',fsample,...
    'info',patch_info,...
    'time',time,...
    'outdir','data',...
    'w',[0 100]/fsample);

end