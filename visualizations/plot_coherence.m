function plot_coherence(data)
%PLOT_COHERENCE plots raw coherence data
%   PLOT_COHERENCE(DATA) plots raw coherence data
%
%   Input
%   -----
%   options
%       feature options struct, see FEATURES.OPTIONS
%   data (struct)
%       raw coherence data
%   data.coef (matrix)
%       coherence function [channels channels freqs]
%   data.f (vector)
%       frequency vector

% Determine layout
[nrows,ncols,~] = size(data.coef);

% calculate maxes and mins
xmin = min(data.f);
xmax = max(data.f);

ymin = min(reshape(abs(data.coef),numel(data.coef),1));
ymax = max(reshape(abs(data.coef),numel(data.coef),1));

% Plot each combination
for i=1:nrows
    for j=1:ncols
        idx_plot = (i-1)*ncols + j;
        
        %     subplot(rows, cols, i);
        subaxis(nrows, ncols, idx_plot,...
            'Spacing', 0, 'SpacingVert', 0.05, 'Padding', 0, 'Margin', 0.1);
        
        if ~isreal(data.coef)
            data_mag = abs(squeeze(data.coef(i,j,:)));
            data_phase = unwrap(angle(squeeze(data.coef(i,j,:))));
            [ax,~,~] = plotyy(data.f, data_mag, data.f, data_phase);
            set(ax(2),'YLim',[-2*pi 2*pi]);
        else
            plot(data.f, abs(squeeze(data.coef(i,j,:))));
        end
        xlim([xmin xmax]);
        ylim([ymin ymax]);
        % TODO Adjust axis spacing
        %label = data.labels{i};
        %title(label(end-3:end));
        % TODO Remove yaxis tick labels
        % TODO Remove xaxis tick labels, keep on first column
        %
        %     if i==nplots
        %        % TODO Add x axis labels
        %     end
        
        % Add channel label as title on first row
        if i == 1 && j == 1
            title(data.name);
        end
        
        % Modify tick labels
%         if col ~= 1
%             % Remove y tick labels
%             set(gca, 'YTickLabel',{});
%         end
        if i == nrows && j == 1
        else
            % Remove y tick labels
            set(gca, 'YTickLabel',{});
            % Remove x tick labels
            set(gca, 'XTickLabel',{});
        end
        
    end
end

end