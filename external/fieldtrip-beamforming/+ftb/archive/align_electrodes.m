function align_electrodes(cfg)
% align_electrodes aligns electrodes, including all of the set up for each
% method type
%
%   Input
%   -----
%   cfg.files.elec_file
%       electrode location file
%   cfg.outputfile
%       output file name
%   cfg.type
%       type of alignment: 'fiducial', 'interactive'
%   cfg.stage.headmodel
%       short name of head model

% Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg

% Load electrodes
elec = ftb.util.loadvar(cfg.files.elec);
% Load head model data
cfgtmp = ftb.get_stage(cfg, 'headmodel');
cfghm = ftb.load_config(cfgtmp.stage.full);

switch cfg.type
    
    case 'fiducial'
        %% Fiducial alignment
        
        % Load MRI data
        if isfield(cfghm.files, 'mri_mat')
            mri = ftb.util.loadvar(cfghm.files.mri_mat);
        else
            mri = ft_read_mri(cfghm.files.mri);
        end
        
        % Get landmark coordinates
        nas=mri.hdr.fiducial.mri.nas;
        lpa=mri.hdr.fiducial.mri.lpa;
        rpa=mri.hdr.fiducial.mri.rpa;
        
        transm=mri.transform;
        
        nas=ft_warp_apply(transm,nas, 'homogenous');
        lpa=ft_warp_apply(transm,lpa, 'homogenous');
        rpa=ft_warp_apply(transm,rpa, 'homogenous');
        
        % create a structure similar to a template set of electrodes
        fid.chanpos       = [nas; lpa; rpa];       % ctf-coordinates of fiducials
        fid.label         = {'FidNz','FidT9','FidT10'};    % same labels as in elec
        fid.unit          = 'mm';                  % same units as mri
        
        % Alignment
        cfgin               = [];
        cfgin.method        = 'fiducial';
        cfgin.template      = fid;                   % see above
        cfgin.elec          = elec;
        cfgin.fiducial      = {'FidNz','FidT9','FidT10'};  % labels of fiducials in fid and in elec
        elec      = ft_electroderealign(cfgin);
        
        % Remove the fiducial labels
%         temp = ft_channelselection({'all','-FidNz','-FidT9','-FidT10'}, elec.label);
        
    case 'interactive'
        %% Interactive alignment
        
        vol = ftb.util.loadvar(cfghm.files.mri_headmodel);
        
        cfgin           = [];
        cfgin.method    = 'interactive';
        cfgin.elec      = elec;
        if isfield(vol, 'skin_surface')
            cfgin.headshape = vol.bnd(vol.skin_surface);
        else
            cfgin.headshape = vol.bnd(1);
        end
        elec  = ft_electroderealign(cfgin);
        
    otherwise
        error(['ftb:' mfilename],...
            'unknown type %s', cfg.type);
        
end

% Save
save(cfg.outputfile, 'elec');

end