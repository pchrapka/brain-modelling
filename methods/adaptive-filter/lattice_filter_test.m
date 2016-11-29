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
%   name, value pairs
%       filter constructor arguments

p = inputParser();
addRequired(p,'filter_name',@ischar);
addParameter(p,'filter_args',{},@iscell);
addParameter(p,'channels',4,@isnumeric);
addParameter(p,'order',3,@isnumeric);
addParameter(p,'samples',1000,@isnumeric);
parse(p,filter_name,varargin{:});

switch filter_name 
    case 'MCMTQRDLSL1'
        ntrials = p.Results.filter_args{1};
    otherwise
        ntrials = 1;
end

% create process and data
process = VRC(p.Results.channels,p.Results.order);
process.coefs_gen_sparse('mode','exact','ncoefs',6);
data = zeros(p.Results.channels, p.Results.samples, ntrials);
for i=1:ntrials
    data(:,:,i) = process.simulate(p.Results.samples);
end

filterhandle = str2func(filter_name);
filter = filterhandle(p.Results.channels,p.Results.order,p.Results.filter_args{:});
trace = LatticeTrace(filter,'fields',{'Kf','Kb'});

trace.run(data,'verbosity',0,'mode','none');

result = isequalntol(squeeze(trace.trace.Kf(end,:,:,:)),...
    process.Kf, 'AbsTol', 0.3);
idx = abs(process.Kf) > 0;
accuracy_percent = sum(result(idx))/length(result(idx));
fprintf('Kf is %0.0f%% OK\n',accuracy_percent*100);
if accuracy_percent < 5/6
    fprintf('True\n');
    print_rc(process.Kf);
    fprintf('Estimated\n');
    print_rc(squeeze(trace.trace.Kf(end,:,:,:)));
end

result = isequalntol(squeeze(trace.trace.Kb(end,:,:,:)),...
    process.Kb, 'AbsTol', 0.3);
idx = abs(process.Kb) > 0;
accuracy_percent = sum(result(idx))/length(result(idx));
fprintf('Kb is %0.0f%% OK\n',accuracy_percent*100);

if accuracy_percent < 5/6
    fprintf('True\n');
    print_rc(process.Kb);
    fprintf('Estimated\n');
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
