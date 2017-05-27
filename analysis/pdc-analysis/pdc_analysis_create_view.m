function view_obj = pdc_analysis_create_view(sources_data_file,varargin)

p = inputParser();
addRequired(p,'sources_data_file',@ischar);
addParameter(p,'downsample',1,@isnumeric);
addParameter(p,'envelope',false,@islogical);
parse(p,sources_data_file,varargin{:});

data = loadfile(sources_data_file);
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

if p.Results.envelope
    view_switch(view_obj,'10');
    % following views at 0-10 Hz
else
    view_switch(view_obj,'beta');
    % following views at 15-25 Hz
end



end