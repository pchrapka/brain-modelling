nchannels = 2;
norder = 4;

flag_new_process = false;
if flag_new_process
    var1 = VAR(1, norder);
    var1.coefs_gen_sparse(...
        'mode','exact','ncoefs',2,'stable',true);
    disp(var1.A)
end

A = zeros(nchannels,nchannels,norder);
A(1,1,:) = [0.3906 0 0 0.6013];
A(2,2,:) = [-0.9349 0 0.2590 0];
A(1,2,3) = 0.8971;

var = VAR(nchannels, norder);
var.coefs_set(A);
var.plot()

flag_new_coupling = false;
if flag_new_coupling
    mask = true(size(A));
    mask(1,1,:) = false(norder,1);
    mask(2,2,:) = false(norder,1);
    var.coefs_gen_coupling(mask,'ncouplings',1);
    var.A
end
var.plot()

%% simulate data
nsamples = 2000;
[x,x_norm,~] = var.simulate(nsamples);

%% estimate AR coefs
[pf,A,pb,B,ef,eb,~] = mcarns(x_norm,norder);

isequalntol(A,var.A,'AbsTol',1e-1,'Verbosity',true);

%% estimate RC coefs
filter = MCMTLOCCD_TWL4(nchannels,norder,1,'lambda',0.99,'gamma',2);
trace_sparse = LatticeTrace(filter,'fields',{'Kf','Kb'});

trace_sparse.run(x_norm);

%%
Kfsp = squeeze(trace_sparse.trace.Kf(nsamples,:,:,:));
Kbsp = squeeze(trace_sparse.trace.Kb(nsamples,:,:,:));

[Arc,Abrc] = rc2ar(Kfsp,Kbsp);
Arc2 = rcarrayformat(Arc,'format',3);
disp(var.A);
disp(Arc2);

vrc = VRC(nchannels,norder);
vrc.coefs_set(Kfsp,Kbsp);
vrc.coefs_stable(true,'method','ar');
vrc.coefs_stable(true,'method','sim');
vrc.plot();

%% estimate RC coefs Burg

filter_burg = BurgVector(nchannels,norder);

trace_burg.run(x_norm);

%%
Kfburg = squeeze(trace_burg.trace.Kf(nsamples,:,:,:));
Kbburg = squeeze(trace_burg.trace.Kb(nsamples,:,:,:));

[Arc,~] = rc2ar(Kfburg,Kbburg);
Arc2 = rcarrayformat(Arc,'format',3);
disp(var.A);
disp(Arc2);

vrc = VRC(nchannels,norder);
vrc.coefs_set(Kfburg,Kbburg);
vrc.coefs_stable(true,'method','ar');
vrc.coefs_stable(true,'method','sim');
vrc.plot();

%% original
