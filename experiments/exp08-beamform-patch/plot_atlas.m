function plot_atlas(atlas, varargin)

% parse inputs
p = inputParser;
addRequired(p, 'atlas', @isstruct);
addParameter(p,'nslices',20,@isnumeric);
addParameter(p,'roi','all');
parse(p,atlas,varargin{:});

% determine which slices have actual data
nslices = size(atlas.tissue,3);
slice_isdata = zeros(nslices,1);
for i=1:nslices
    slice_isdata(i) = any(any(atlas.tissue(:,:,i)));
end
slice_idx = 1:nslices;
slice_idx_isdata = slice_idx(logical(slice_isdata));

% select slices to plot
nsliceplots = p.Results.nslices;
slice_idx_plot = linspace(slice_idx_isdata(1),slice_idx_isdata(end), nsliceplots);
slice_idx_plot = ceil(slice_idx_plot);

% select roi to plot
if ~isequal(p.Results.roi,'all')
    % match roi label to index
    nrois = length(p.Results.roi);
    roi_idx = zeros(nrois,1);
    for i=1:nrois
        match = lumberjack.strfindlisti(atlas.tissuelabel, p.Results.roi{i});
        if ~any(match)
            error('could not find %s', p.Results.roi{i});
        end
        roi_idx(i) = find(match == 1);
    end
    
end

% plot slices
figure;
rows = ceil(sqrt(nsliceplots));
cols = ceil(nsliceplots/rows);
for i=1:nsliceplots
    %subplot(rows,cols,i);
    subaxis(rows, cols, i,...
                'Spacing', 0, 'SpacingVert', 0.05, 'Padding', 0, 'Margin', 0.05);
    if isequal(p.Results.roi,'all')
        imagesc(atlas.tissue(:,:,slice_idx_plot(i)));
    else
        slice_data = atlas.tissue(:,:,slice_idx_plot(i));

        % create mask for selected ROIs
        mask = zeros(size(slice_data));
        for j=1:nrois
            % for the current ROI, set each voxel to 1
            mask(slice_data == roi_idx(j)) = 1;
        end
        
        iscontrast = true;
        if iscontrast
            % apply the mask
            slice_image = zeros(size(slice_data));
            slice_image(slice_data > 0) = 0.5;
            slice_image = slice_image + 0.5*mask;
            imagesc(slice_image,[0 1]);
        else
            % apply the mask
            slice_image = slice_data.*mask;
            
            imagesc(slice_image);
        end
    end
    axis square
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
end

end