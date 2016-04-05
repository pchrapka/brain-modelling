%% runtests
clc;
import matlab.unittest.TestSuite

verbosity = 1;

%% Run tests
suite = TestSuite.fromPackage('tests');

% Show tests
if verbosity > 0
    disp({suite.Name}');
end
result = run(suite);