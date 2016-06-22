%% runtests
clc;
close all;
import matlab.unittest.TestSuite

verbosity = 1;

%% Run tests
% suite = TestSuite.fromPackage('tests');
% 
% % Show tests
% if verbosity > 0
%     disp({suite.Name}');
% end
% result = run(suite);

% suite = TestSuite.fromClass(?tests.TestPipelineLatticeSVM);
% if verbosity > 0
%     disp({suite.Name}');
% end
% result = run(suite);

suite = TestSuite.fromClass(?tests.TestSVM);
if verbosity > 0
    disp({suite.Name}');
end
result = run(suite);