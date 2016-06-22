function labels = lattice_feature_labels(dims)
%LATTICE_FEATURE_LABELS creates labels for each lattice feature

time = dims(1);
order = dims(2);
channels = dims(3);

labels = cell(time,order,channels,channels);
for i=1:time
    for j=1:order
        for k=1:channels
            for m=1:channels
                labels{i,j,k,m} = sprintf('t%d-p%d-c%d-c%d',i,j,k,m);
            end
        end
    end
end

end