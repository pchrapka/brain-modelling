function hemis = get_hemi(obj,atlas)

nlabels = length(obj.label);
hemis = struct('name','','order',num2cell(zeros(nlabels,1)));
for i=1:nlabels
    
    switch atlas
        case 'aal'
            [hemis(i).name, hemis(i).order] = ChannelInfo.get_hemi_aal(obj.label{i},'single');
        case {'aal-coarse-13','aal-coarse-19','aal-coarse-19-plus2'}
            [hemis(i).name, hemis(i).order] = ChannelInfo.get_hemi_aal(obj.label{i},'full');
        otherwise
            error('unknown atlas %s',atlas);
    end
    
    %disp(obj.label{i});
    %disp(hemis(i));
end

end