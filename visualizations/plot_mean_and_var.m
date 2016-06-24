function h = plot_mean_and_var(x,y_mean,y_var,varargin)

x = x(:);
y_var = y_var(:);
y_mean = y_mean(:);

y_sigma = sqrt(y_var);
h = patch([x; flipud(x)], [y_mean+y_sigma; flipud(y_mean-y_sigma)], varargin{:});
% for i=1:length(h)
%     set(h(i),'FaceAlpha',0.3);
%     set(h(i),'EdgeColor','None');
% end

end