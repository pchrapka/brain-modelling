%% exp22_explore_rc

pipeline = build_pipeline_lattice_svm('params_sd_22');

% filter_params = 'params_lf_MQRDLSL2_p10_l099_n400';
filter_params = 'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400';

% select jobs based on filter params
brick_name = 'bricks.lattice_filter_sources';
brick_code = pipeline.get_brick_code(brick_name);
param_code = pipeline.get_params_code(brick_name,filter_params);

pattern = ['.+' brick_code param_code '\>'];
jobs = fieldnames(pipeline.pipeline);
job_idx = cellfun(@(x) ~isempty(regexp(x,pattern,'match')),jobs,'UniformOutput',true);
jobs_desired = jobs(job_idx);

% load file list of filtered data
file_filtered_data = pipeline.pipeline.(jobs_desired{1}).files_out;
filtered_list = ftb.util.loadvar(file_filtered_data);

% select a few
nfiles = 3;
filtered_list = filtered_list(1:3);

comp_name = get_compname();
% mode = 'image-all';
% mode = 'image-order';
% mode = 'image-max';
% mode = 'movie-order';
mode = 'movie-max';
figure;

for i=1:1%length(filtered_list)
    if ~isempty(strfind(comp_name,'Valentina'))
        % replace the root dir depending on the comp we're using
        filtered_list{i} = strrep(filtered_list{i},...
            get_root_dir('blade16.ece.mcmaster.ca'),...
            get_root_dir('Valentina'));
    end
    data = ftb.util.loadvar(filtered_list{i});
    
    % TODO do stuff
    switch mode
        case 'image-all'
            % plot all reflection coefs
            niters = size(data.Kf,1);
            ncoefs = numel(data.Kf)/niters;
            rc = reshape(data.Kf,niters,ncoefs);
            rc = rc';
            clim = [-1.5 1.5];
            imagesc(rc,clim);
            colorbar;
            xlabel('Time');
            ylabel('Reflection Coefficients');
        case 'image-order'
            norder = size(data.Kf,2);
            niters = size(data.Kf,1);
            clim = [-1.5 1.5];
            
            nplots = norder;
            ncols = 2;
            nrows = ceil(nplots/ncols);
            for j=1:norder
                subplot(nrows,ncols,j);
                ncoefs = numel(squeeze(data.Kf(:,j,:,:)))/niters;
                rc = reshape(data.Kf(:,j,:,:),niters,ncoefs);
                rc = rc';
                imagesc(rc,clim);
                axis square;
                ylabel(sprintf('P=%d',j));
                
                if j==norder
                    colorbar;
                    xlabel('Time');
                end
            end
        case 'image-max'
            data_max = squeeze(max(data.Kf,[],2));
            niters = size(data_max,1);
            ncoefs = numel(data_max)/niters;
            rc = reshape(data_max,niters,ncoefs);
            rc = rc';
            clim = [-1.5 1.5];
            imagesc(rc,clim);
            axis square;
            colorbar;
            xlabel('Time');
            ylabel('Reflection Coefficients');
            
            
        case 'movie-order'
            norder = size(data.Kf,2);
            niters = size(data.Kf,1);
            clim = [-1.5 1.5];
            
            nplots = norder;
            ncols = 2;
            nrows = ceil(nplots/ncols);
            for k=1:niters
                for j=1:norder
                    subplot(nrows,ncols,j);
                    rc = squeeze(data.Kf(k,j,:,:));
                    imagesc(rc,clim);
                    axis square;
                    ylabel(sprintf('P=%d',j));
                    
                    if j==1
                        title(sprintf('Time = %d/%d',k,niters));
                    end
                    
                    if j==norder
                        colorbar;
                        xlabel('Time');
                    end
                end
                drawnow();
                %pause(0.005);
            end
        case 'movie-max'
            niters = size(data.Kf,1);
            clim = [-1.5 1.5];
            
            for k=1:niters
                data_k = squeeze(data.Kf(k,:,:,:));
                data_max = squeeze(max(data_k,[],1));
                imagesc(data_max,clim);
                axis square;
                title(sprintf('Time = %d/%d',k,niters));
                
                colorbar;
                xlabel('Time');
                ylabel('Reflection Coefficients');
                title({'Max Reflection Coefficient',...
                    sprintf('Time = %d/%d',k,niters)});
                drawnow();
                %pause(0.005);
            end
        otherwise
    end
end