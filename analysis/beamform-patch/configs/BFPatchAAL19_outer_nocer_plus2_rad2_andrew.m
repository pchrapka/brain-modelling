function cfg = BFPatchAAL19_outer_nocer_plus2_rad2_andrew(data_name)
% BFPatchAAL

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

cfg = [];
sphere_patch = {};
sphere_patch{1} = {'Auditory Left',locsmni(1,:),'radius',2};
sphere_patch{2} = {'Auditory Right',locsmni(2,:),'radius',2};
cfg.PatchModel = {'aal-coarse-19','params',{'type','outer-nocerebellum'},'sphere_patch',sphere_patch};

cfg.cov_avg = 'yes';
cfg.compute_lcmv_patch_filters = {'mode','single','fixedori',true}; % for saving mem
% cfg.compute_lcmv_patch_filters = {'mode','all','fixedori',true}; % for plotting
cfg.ft_sourceanalysis.rawtrial = 'yes';
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';
cfg.ft_sourceanalysis.lcmv.lambda = '1%';
switch data_name(1:3)
    case 's06'
        cfg.ft_sourceanalysis.channel = {'EEG','-D32','-C10'};
    otherwise
        warning('update bad EEG channels for ft_sourceanalysis in %s',mfilename);
end

cfg.name = sprintf('%s-%s-%s',...
    [cfg.PatchModel{1} '-outer-plus2-rad2'],...
    cfg.ft_sourceanalysis.method,...
    data_name(1:3));

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end