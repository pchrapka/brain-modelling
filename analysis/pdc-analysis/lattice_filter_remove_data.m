function out = lattice_filter_remove_data(lf_files,samples)

p = inputParser();
addRequired(p,'lf_files',@iscell);
addRequired(p,'samples',@(x) (length(x)==2) && isnumeric(x));
parse(p,lf_files,samples);

nfiles = length(lf_files);
out = cell(nfiles,1);
for i=1:nfiles
    out{i} = strrep(lf_files{i},'.mat','-removed.mat');
    if ~exist(out{i},'file') || isfresh(out{i},lf_files{i})
        data = loadfile(lf_files{i});
        
        fields = fieldnames(data.estimate);
        nfields = length(fields);
        for j=1:nfields
            field = fields{j};
            dims = size(data.estimate.(field));
            ndims = length(dims);
            switch ndims
                case 3
                    data.estimate.(field)(samples(1):samples(2),:,:) = [];
                case 4
                    data.estimate.(field)(samples(1):samples(2),:,:,:) = [];
            end
        end
        
        % save in a new file
        save_parfor(out{i},data);
    end
end

end