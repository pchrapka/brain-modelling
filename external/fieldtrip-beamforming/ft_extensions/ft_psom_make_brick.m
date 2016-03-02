function fcn = ft_psom_make_brick(cfg)

% opt = cfg;
% in = cfg.inputfile;
% out = cfg.outputfile;
fcn = @brick;

    function out = brick(in, out, opt)
        out = opt.ft_func(opt);
    end

end