function setup_parfor()

[ret, comp_name] = system('hostname'); 

if ret ~= 0
    if ispc
        comp_name = getenv('COMPUTERNAME');
    else
        comp_name = getenv('HOSTNAME');
    end
end
    

switch comp_name
    case 'blade16.ece.mcmaster.ca'
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
    otherwise
        fprintf('%s: using default config\n', mfilename);
end

end