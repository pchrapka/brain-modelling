function lattice_filter_test(filter_name, varargin)
%LATTICE_FILTER_TEST tests lattice filter
%   LATTICE_FILTER_TEST tests lattice filter
%
%   Input
%   -----
%   filter_name
%       filter object name
%
%   Parameters
%   ----------
%   varargin
%       filter constructor arguments

K = 4;
order = 3;

% test constructor
process = VRC(K,order);
process.coefs_gen_sparse('mode','exact','ncoefs',6);
data = process.simulate(1000);

filterhandle = str2func(filter_name);
filter = filterhandle(K,order,varargin{:});
trace = LatticeTrace(filter,'fields',{'Kf','Kb'});

trace.run(data,'verbosity',0,'mode','none');

result = isequalntol(squeeze(trace.trace.Kf(end,:,:,:)),...
    process.Kf, 'AbsTol', 0.3);
idx = abs(process.Kf) > 0;
accuracy_percent = sum(result(idx))/length(result(idx));
fprintf('Kf is %d%% OK\n',accuracy_percent*100);
if accuracy_percent < 0.9
    print_rc(process.Kf);
    print_rc(squeeze(trace.trace.Kf(end,:,:,:)));
end

result = isequalntol(squeeze(trace.trace.Kb(end,:,:,:)),...
    process.Kb, 'AbsTol', 0.3);
idx = abs(process.Kb) > 0;
accuracy_percent = sum(result(idx))/length(result(idx));
fprintf('Kb is %d%% OK\n',accuracy_percent*100);

if accuracy_percent < 0.9
    print_rc(process.Kb);
    print_rc(squeeze(trace.trace.Kb(end,:,:,:)));
end
end

function print_rc(coefs)
norder = size(coefs,1);
for i=1:norder
    fprintf('order: %d\n',i);
    disp(squeeze(coefs(i,:,:)));
end
end
