%% ftb_runtests
clc;
import matlab.unittest.TestSuite

verbosity = 1;

%% Run tests in features package
suite = TestSuite.fromPackage('ftb.tests');
%suite = TestSuite.fromFolder(fullfile(pwd,'..','+ftb','tests'));
% Show tests
if verbosity > 0
    disp({suite.Name}');
end
result = run(suite);
