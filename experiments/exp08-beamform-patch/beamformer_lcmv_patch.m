function [filters, patch_labels] = beamformer_lcmv_patch(...
    data, leadfield, atlasfile, patches, varargin)

p = inputParser;
addRequired(p,'data',@isstruct);
addRequired(p,'leadfield',@isstruct);
addRequired(p,'atlasfile',@ischar);
addRequired(p,'patches',@isstruct);
% add options
parse(p,data,leadfield,atlasfile,patches,varargin{:});

% load the atlas
atlas = ft_read_atlas(p.Results.atlas_file);
atlas = ft_convert_units(atlas,'cm');

% TODO allocate filter mem
filters = cell();
patch_labels = cell();
% TODO check how filters look like in sourceanalysis struct from BFCommon

% TODO
for i=1:length(patches)
    % TODO select grid points in patch
    
    % select anatomical patch
    cfg = [];
    cfg.atlas = atlas;
    cfg.roi = patches(i).labels;
    cfg.inputcoord = 'mni';
    mask = ft_volumelookup(cfg, leadfield.grid);
    
    % select grid points inside patch
    tmp = false(size(leadfield.grid.inside));
    tmp(mask) = 1;
    grid_sel = leadfield.grid;
    grid_sel.inside = tmp;
    
    % get leadfields in patch
    lf_patch = leadfield.leadfield(grid_sel.inside);
    
    % TODO generate basis for patch
    
    % TODO compute lcmv patch filter
    
    % use patch filter for each point in patch
    filters{grid_sel.inside} = filter;
    % NOTE Redundant, but it keeps everything else in Fieldtrip working
    % as normal
    
    % TODO it'd be nice to have a patch label for each point
    patch_labels{grid_sel.inside} = patches(i).name;
    
end

end