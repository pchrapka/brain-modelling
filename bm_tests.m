    %% runtests
clc;
close all;
import matlab.unittest.TestSuite

verbosity = 1;

%% Run all tests
% suite = TestSuite.fromPackage('tests');
% suite = TestSuite.fromPackage('fthelpers');
% 
% % Show tests
% if verbosity > 0
%     disp({suite.Name}');
% end
% result = run(suite);

%% Included in all
% Run some subsets

% suite = TestSuite.fromClass(?tests.TestPipelineLatticeSVM);
% suite = TestSuite.fromClass(?tests.TestSVM);
% suite = TestSuite.fromClass(?tests.Test_plot_rc_feature_matrix);
% suite = TestSuite.fromClass(?tests.TestVAR);
% suite = TestSuite.fromClass(?tests.TestVRC);
% suite = TestSuite.fromClass(?tests.Test_rc2ar);
% suite = TestSuite.fromClass(?tests.TestFilters);
suite = TestSuite.fromClass(?tests.TestChannelInfo);
if verbosity > 0
    disp({suite.Name}');
end
result = run(suite);

%% Not included in all
% Test_ft_trialfun_preceed

% [srcdir,~,~] = fileparts(mfilename('fullpath'));
% suite = TestSuite.fromFolder(fullfile(srcdir,'analysis'),'IncludingSubfolders',true);
% if verbosity > 0
%     disp({suite.Name}');
% end
% result = run(suite);