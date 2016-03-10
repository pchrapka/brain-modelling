function plot_moment(obj,varargin)
%PLOT_MOMENT plots the source moment
%   PLOT_MOMENT(obj, [mode,...]) plots the source moment
%
%   Input
%   -----
%   mode (string, optional, default = '2d-all')
%       '2d-all' - plots all sources 
%       '2d-top' - plots top N sources by power
%       '1d-top' - plots top N (max 10) sources in subplots
%
%   Parameters
%   nsources
%       specifies number of sources to plot when mode = '2d-top', default 10

% parse inputs
p = inputParser;
addOptional(p,'mode','2d-all',@(x) any(validatestring(x,{'2d-all','2d-top','1d-top'})));
addParameter(p,'nsources',10,@isnumeric);
parse(p,varargin{:});            

source = ftb.util.loadvar(obj.sourceanalysis);
if ~isfield(source.avg,'mom')
    error(['ftb:' mfilename],...
        'need source moments, see keepmoments option in ft_sourceanalysis');
end

mom_inside = source.avg.mom(source.inside);

% check how many components we have
[ncomp, nsamples] = size(mom_inside{1});
nmom = length(mom_inside);
data = zeros(nmom,nsamples);
if ncomp > 1
    % compute moment power at each time step
    for i=1:nmom
        data(i,:) = sqrt(sum(mom_inside{i}.^2));
    end
else
    % copy moments into array
    for i=1:nmom
        data(i,:) = mom_inside{i};
    end
end

if strfind(p.Results.mode,'top')
    % sort data based on source power
    pow = sum(data,2);
    temp = [pow data];
    data_sorted = sortrows(temp,-1);
end

switch p.Results.mode
    case '2d-all'
        imagesc(data)
        xlabel('time');
        ylabel('location');
        colorbar
        
    case '2d-top'
        imagesc(data_sorted(1:p.Results.nsources,2:end))
        xlabel('time');
        ylabel('location');
        colorbar
        
    case '1d-top'
        nsources = min([10 p.Results.nsources]);
        for i=1:nsources
            subplot(nsources,1,i);
            plot(data_sorted(i,2:end));
            if i~=nsources
                set(gca,'xticklabel',[]);
            end
        end
        
end

end