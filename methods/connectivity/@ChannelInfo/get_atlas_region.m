function regions = get_atlas_region(obj,atlas)

nlabels = length(obj.label);
regions = struct('name','','order',num2cell(zeros(nlabels,1)));
for i=1:nlabels
    switch atlas
        case 'aal'
            [regions(i).name, regions(i).order] =...
                ChannelInfo.get_atlas_region_aal(obj.label{i});
        case 'aal-coarse-13'
            [regions(i).name, regions(i).order] =...
                ChannelInfo.get_atlas_region_aal_coarse_13(obj.label{i});
        case 'aal-coarse-19'
            [regions(i).name, regions(i).order] =...
                ChannelInfo.get_atlas_region_aal_coarse_19(obj.label{i});
        case {'aal-coarse-19-plus2', 'aal-coarse-19-outer-plus2','aal-coarse-19-outer-nocer-plus2'}
            [regions(i).name, regions(i).order] =...
                ChannelInfo.get_atlas_region_aal_coarse_19_plus2(obj.label{i});
        otherwise
            error('unknown atlas %s',atlas);
    end
end

end