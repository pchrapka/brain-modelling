%% lattice_filter_test_script

nsamples = 1000;
nchannels = 4;
trials = 10;
sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));
gamma = 0.2;

lambda = 0.99;

lattice_filter_test('MQRDLSL1','filter_args',{lambda});
lattice_filter_test('MQRDLSL2','filter_args',{lambda});
lattice_filter_test('MCMTQRDLSL1','filter_args',{trials,0.99});
lattice_filter_test('MLOCCD_TWL','filter_args',{'lambda',lambda,'gamma',gamma}); % fix everything
lattice_filter_test('MLOCCD_TWL2','filter_args',{'lambda',lambda,'gamma',gamma});
lattice_filter_test('BurgVectorWindow','filter_args',{'nwindow',60});
lattice_filter_test('BurgVector','filter_args',{'nsamples',nsamples});