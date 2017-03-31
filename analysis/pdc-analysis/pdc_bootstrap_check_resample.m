function pdc_bootstrap_check_resample(file_pdc_sig,resample_idx,varargin)
p = inputParser();
addRequired(p,'file_pdc_sig',@ischar);
addRequired(p,'resample_idx',@isnumeric);
addParameter(p,'eeg_file','',@ischar);
addParameter(p,'leadfield_file','',@ischar);
addParameter(p,'envelope',false,@islogical)
addParameter(p,'patch_type','',@ischar);
parse(p,file_pdc_sig,resample_idx,varargin{:});

[workingdir,sig_filename,~] = fileparts(file_pdc_sig);
[~,filter_name,~] = fileparts([workingdir '.mat']);
filter_name = strrep(filter_name,'-bootstrap','');

% get tag between [pdc-dynamic-...-ds\d]-sig
pattern = '.*(pdc-dynamic-.*)-sig';
result = regexp(sig_filename,pattern,'tokens');
pdc_tag = result{1}{1};

resampledir = sprintf('resample%d',resample_idx);
file_pdc_resample = fullfile(workingdir, resampledir, sprintf('%s-%s.mat',filter_name,pdc_tag));

view_obj = pdc_analysis_create_view(...
    file_pdc_resample,...
    p.Results.eeg_file,...
    p.Results.leadfield_file,...
    'envelope',p.Results.envelope,...
    'patch_type',p.Results.patch_type);

if p.Results.envelope
    view_switch(view_obj,'10')
    % following views at 0-10 Hz
else
    view_switch(view_obj,'beta')
    % following views at 15-25 Hz
end
nchannels = length(view_obj.info.label);

directions = {'outgoing','incoming'};
for direc=1:length(directions)
    for ch=1:nchannels
        
        created = view_obj.plot_seed(ch,...
            'direction',directions{direc},...
            'threshold_mode','numeric',...
            'threshold',0.001,...
            'vertlines',[0 0.5]);
        
        if created
            view_obj.save_plot('save',true,'engine','matlab');
        end
        close(gcf);
    end
end





end