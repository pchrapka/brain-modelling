function hemis = get_hemi(obj,atlas)

atlas_options = {'aal-coarse','aal'};
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

nlabels = length(obj.label);
hemis = struct('name','','order',num2cell(zeros(nlabels,1)));
for i=1:nlabels
    
    switch atlas_name
        case 'aal'
            [hemis(i).name, hemis(i).order] = ChannelInfo.get_hemi_aal(obj.label{i},'single');
        case 'aal-coarse'
            [hemis(i).name, hemis(i).order] = ChannelInfo.get_hemi_aal(obj.label{i},'full');
        otherwise
            error('unknown atlas %s',atlas);
    end
    
    %disp(obj.label{i});
    %disp(hemis(i));
end

end