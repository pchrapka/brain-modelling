function cfg = BFPatchAAL19_andrew(data_name,varargin)
% BFPatchAAL

p = inputParser();
addRequired(p,'data_name',@ischar);
addParameter(p,'flag_add_auditory',false,@islogical);
addParameter(p,'flag_add_v1',false,@islogical);
addParameter(p,'outer',false,@islogical);
addParameter(p,'cerebellum',true,@islogical);
addParameter(p,'hemisphere','both',@ischar);
parse(p,data_name,varargin{:});

patchmodel_params = {...
    'outer',p.Results.outer,...
    'cerebellum',p.Results.cerebellum,...
    'hemisphere',p.Results.hemisphere};

% set up tags for the patchmodel name
base_name = 'aal-coarse-19';

if p.Results.outer
    tag_outer = '-outer';
else
    tag_outer = '';
end

if p.Results.cerebellum
    tag_cerebellum = '';
else
    tag_cerebellum = '-nocer';
end

if isequal(p.Results.hemisphere,'both')
    tag_hemisphere = '';
else
    tag_hemisphere = sprintf('-hemi%s',p.Results.hemisphere);
end

patchmodel_name = [base_name tag_outer tag_cerebellum tag_hemisphere];

sphere_patch = {};
sphere_idx = 1;
if p.Results.flag_add_auditory
    % P1 dipoles in Talaraich coordinates
    switch data_name(1:3)
        case 's03'
            loc_l = [-34.357361   -8.505583   +9.360396];
            %         '12: no_label_found'
            %         '5: Insula_L'
            %         '3: Putamen_L'
            %         '3: Thalamus_L'
            %         '2: Rolandic_Oper_L'
            %         '2: Caudate_L'
            %         '2: Heschl_L'
            %         '1: Precentral_L'
            %         '1: Pallidum_L'
            %         '1: Temporal_Sup_L'
            
            loc_r = [+34.357361   -8.505583   +9.360396];
            %         '9: no_label_found'
            %         '6: Insula_R'
            %         '5: Putamen_R'
            %         '4: Thalamus_R'
            %         '3: Rolandic_Oper_R'
            %         '3: Caudate_R'
            %         '1: Pallidum_R'
            %         '1: Heschl_R'
        otherwise
            warning([mfilename ':dipoles'],'using default P1 dipoles');
            loc_l = [ -45.0, -3.2, 16.2];
            loc_r = [ 45.0, -3.2, 16.2];
    end
    locs = [loc_l; loc_r];
    locsmni = tal2mni(locs);
    locsmni = locsmni/10; % convert to cm
    
    % add based on hemisphere selection
    switch p.Results.hemisphere
        case 'both'
            flag_left = true;
            flag_right = true;
        case 'right'
            flag_left = false;
            flag_right = true;
        case 'left'
            flag_left = true;
            flag_right = false;
        otherwise
            error('unknown hemi %s',p.Results.hemisphere);
    end
    
    if flag_left
        sphere_patch{sphere_idx} = {'Auditory Left',locsmni(1,:),'radius',2};
        sphere_idx = sphere_idx + 1;
    end
    
    if flag_right
        sphere_patch{sphere_idx} = {'Auditory Right',locsmni(2,:),'radius',2};
        sphere_idx = sphere_idx + 1;
    end
    
    patchmodel_name = sprintf('%s-audr2',patchmodel_name);
end

if p.Results.flag_add_v1
    locsmni = [0 -9 0]; % already in mni and cm
    %     '12: Calcarine_L'
    %     '5: no_label_found'
    %     '3: Calcarine_R'
    %     '3: Lingual_L'
    %     '3: Lingual_R'
    %     '1: Cuneus_L'
    %     '1: Occipital_Sup_L'
    %     '1: Occipital_Mid_L'
    
    sphere_patch{sphere_idx} = {'V1 Mid',locsmni,'radius',2};
    sphere_idx = sphere_idx + 1;
    
    patchmodel_name = sprintf('%s-v1r2',patchmodel_name);
end

cfg = [];
cfg.patchmodel_name = patchmodel_name;
cfg.PatchModel = {'aal-coarse-19','params',patchmodel_params,'sphere_patch',sphere_patch};

cfg.cov_avg = 'yes';
cfg.compute_lcmv_patch_filters = {'mode','single','fixedori',true}; % for saving mem
% cfg.compute_lcmv_patch_filters = {'mode','all','fixedori',true}; % for plotting
cfg.ft_sourceanalysis.rawtrial = 'yes';
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';
cfg.ft_sourceanalysis.lcmv.lambda = '1%';
switch data_name(1:3)
    case 's03'
        % all good
    case 's06'
        cfg.ft_sourceanalysis.channel = {'EEG','-D32','-C10'};
    otherwise
        warning('update bad EEG channels for ft_sourceanalysis in %s',mfilename);
end

cfg.name = sprintf('%s-%s-%s',...
    patchmodel_name,...
    cfg.ft_sourceanalysis.method,...
    data_name(1:3));

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end