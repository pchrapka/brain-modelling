function params = data_beta_config()
%DATA_BETA_CONFIG configuration for beta data from Andrew

% get the data folder
comp_name = get_compname();
switch comp_name
    case {'blade16.ece.mcmaster.ca', sprintf('blade16.ece.mcmaster.ca\n')}
        rootdir = get_root_dir(comp_name);
        data_dir = fullfile(rootdir,'projects','data-andrew-beta');
    case {sprintf('Valentina\n')}
        rootdir = '/media/phil/p.eanut';
        data_dir = fullfile(rootdir,'projects','data-andrew-beta');
    otherwise
        error([mfilename ':MissingConfig'],['new computer, where is the data?\n'...
            'add your computer and the data directory to %s'],mfilename);
end

% set up outputs
if ~exist(data_dir,'dir')
    error([mfilename ':MissingData'],...
        'cannot find the data dir: %s',data_dir);
end

params.data_dir = data_dir;

end