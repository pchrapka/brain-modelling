function pdc_bootstrap_check_resample(file_pdc_sig,resample_idx,varargin)
p = inputParser();
addRequired(p,'file_pdc_sig',@ischar);
addRequired(p,'resample_idx',@isnumeric);
addParameter(p,'eeg_file','',@ischar);
addParameter(p,'leadfield_file','',@ischar);
addParameter(p,'envelope',false,@islogical)
addParameter(p,'patch_type','',@ischar);
parse(p,file_pdc_sig,resample_idx,varargin{:});

error('deprecated');

[workingdir,sig_filename,~] = fileparts(file_pdc_sig);
[~,filter_name,~] = fileparts([workingdir '.mat']);
pattern = '(.*)-bootstrap.*';
result = regexp(filter_name,pattern,'tokens');
filter_name = result{1}{1};

% get tag between [pdc-dynamic-...-ds\d]-sig
pattern = '.*(pdc-dynamic-.*)-sig';
result = regexp(sig_filename,pattern,'tokens');
pdc_tag = result{1}{1};

resampledir = sprintf('resample%d',resample_idx);
file_pdc_resample = fullfile(workingdir, resampledir, sprintf('%s-%s.mat',filter_name,pdc_tag));

view_obj = pdc_analysis_create_view(... 
    p.Results.eeg_file,...
    p.Results.leadfield_file,...
    'patch_type',p.Results.patch_type);
view_obj.file_pdc = file_pdc_resample;

if p.Results.envelope
    view_switch(view_obj,'10')
    % following views at 0-10 Hz
else
    view_switch(view_obj,'beta')
    % following views at 15-25 Hz
end

params_plot = {...
    'threshold_mode','numeric',...
    'threshold',0.001,...
    'vertlines',[0 0.5],...
    };
pdc_plot_seed_all(view_obj_resample,params_plot{:});

end