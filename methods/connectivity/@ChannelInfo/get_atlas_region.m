function regions = get_atlas_region(obj,atlas)

nlabels = length(obj.label);
regions = struct('name','','order',num2cell(zeros(nlabels,1)));

atlas_options = {'aal-coarse-19','aal-coarse-13','aal'};
atlas_name = [];
for i=1:length(atlas_options)
    result = strfind(atlas,atlas_options{i});
    if ~isempty(result)
        atlas_name = atlas_options{i};
        break;
    end
end

if isempty(atlas_name)
    error('unknown atlas %s',atlas);
end

for i=1:nlabels
    switch atlas_name
        case 'aal-coarse-19'
            [regions(i).name, regions(i).order] =...
                ChannelInfo.get_atlas_region_aal_coarse_19(obj.label{i});
        case 'aal-coarse-13'
            [regions(i).name, regions(i).order] =...
                ChannelInfo.get_atlas_region_aal_coarse_13(obj.label{i});
        case 'aal'
            [regions(i).name, regions(i).order] =...
                ChannelInfo.get_atlas_region_aal(obj.label{i});
        otherwise
            error('implement atlas %s',atlas_name);
    end
end

end