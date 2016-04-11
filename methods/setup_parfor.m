function setup_parfor(comp_name)

switch comp_name
    case 'blade'
        if verLessThan('matlab', '8.2.0.29') % R2013b
            matlabpool('open', 10);
        else
            % close the current pool
            if ~isempty(gcp)
                delete(gcp);
            end
            % set up a new one
            parpool('local', 10);
        end
    case 'laptop'
        if isempty(gcp)
            parpool('local',2);
        end
    otherwise
        error('unknown computer name');
end

end