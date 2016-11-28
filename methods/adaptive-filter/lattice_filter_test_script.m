%% lattice_filter_test_script

nsamples = 1000;
nchannels = 4;
trials = 1;
sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

lattice_filter_test('MQRDLSL1',0.99);
lattice_filter_test('MQRDLSL2',0.99);
lattice_filter_test('MCMTQRDLSL1',trials,0.99);
lattice_filter_test('MLOCCD_TWL','lambda',lambda,'gamma',gamma);
lattice_filter_test('MLOCCD_TWL2','lambda',lambda,'gamma',gamma);
lattice_filter_test('BurgVectorWindow','nwindow',60);
lattice_filter_test('BurgVector','nsamples',nsamples);