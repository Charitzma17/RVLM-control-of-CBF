% Load coordinate matrix (6x25) with coordinates of all areas of
% interest...
load('coordinates_april2025.mat');  % variable name: coordinate_limits

nregions = size(coordinate_limits, 2);
% Assume coordinate_limits is [6 x num_regions]:
% rows = [rc_start; rc_end; dv_start; dv_end; ml_start; ml_end]
rvlm_coord = [-6.75, 5.9, 1.25];  % [RC, DV, ML]
% Get center coordinates
rc_center = mean(coordinate_limits(1:2, :));
dv_center = mean(coordinate_limits(3:4, :));
ml_center = mean(coordinate_limits(5:6, :));

% 3D coordinates for all regions
coords = [rc_center; dv_center; ml_center];  % 3 x N
threshold = 0.7;
adj = pearson_corr > threshold;
adj = adj - diag(diag(adj));  % remove self-connections

% Find connected region pairs (i,j)
[row, col] = find(triu(adj));  % upper triangle = no duplicates
edges = [row, col];
figure('Position', [0, 0, 900, 800],'Color', 'w'); hold on;
% --- 1. Add RVLM Node ---
scatter3(rvlm_coord(1), rvlm_coord(2), rvlm_coord(3), ...
    500, 'filled', 'MarkerFaceColor',[0.8 0 0] , 'MarkerEdgeColor', [0.8 0 0]);
text(rvlm_coord(1), rvlm_coord(2), rvlm_coord(3) - 0.8, ...
    'RVLM', 'FontSize', 22,'FontName','Arial', 'Color', [0.8 0 0], ...
    'HorizontalAlignment', 'center');

% --- 2. Connect RVLM to AAV+ regions ---
for i = 1:length(list)
    if ismember(list{i}, listAAV)
        % Draw line from RVLM to region i
        plot3([rvlm_coord(1), rc_center(i)], ...
            [rvlm_coord(2), dv_center(i)], ...
            [rvlm_coord(3), ml_center(i)], ...
            '-', 'Color', [0.8 0 0], 'LineWidth', 1);  % semi-transparent red
    end
end
% Define cortex targets
cortex_targets = {'SSC', 'MC', 'VisC', 'AuC'};

% Color map for cortical target nodes and labels
cortex_color_map = containers.Map( ...
    {'AuC', 'MC', 'SSC', 'VisC'}, ...
    { ...
    [0 0 0], ...             % AuC → black
    [0.7 0.7 0.7], ...       % MC → grey
    [0.76 0.60 0.42], ...    % SSC → light brown
    [0.9 0.7 0] ...           % VisC → golden yellow
    } ...
    );



% Plot edges (correlated region pairs)
for k = 1:size(edges,1)
    i = edges(k,1);
    j = edges(k,2);

    plot3([rc_center(i) rc_center(j)], ...
        [dv_center(i) dv_center(j)], ...
        [ml_center(i) ml_center(j)], ...
        'k-', 'LineWidth', 0.5, 'Color', [0.2 0.2 0.2 0.05]);  % semi-transparent
end
% Define high-order cortical targets (case-sensitive match)
cortex_targets = {'SSC', 'MC', 'VisC', 'AuC'};

% Step 1: Draw red lines from RVLM to listAAV (already done above)

% Step 2: Draw colored lines from listAAV → cortex targets
color_map = containers.Map( ...
    {'AuC', 'MC', 'SSC', 'VisC'}, ...
    {[0 0 0], [0.7 0.7 0.7], [0.76 0.60 0.42], [0.9 0.7 0]} ...
    );

for i = 1:length(list)
    src_name = list{i};

    % Only if region is AAV+
    if ismember(src_name, listAAV)
        for j = 1:length(list)
            tgt_name = list{j};
            if ismember(tgt_name, cortex_targets) && ...
                    pearson_corr(i, j) > threshold

                % Color by cortical target
                edge_color = color_map(tgt_name);

                % Draw edge from AAV+ → cortical region
                plot3([rc_center(i), rc_center(j)], ...
                    [dv_center(i), dv_center(j)], ...
                    [ml_center(i), ml_center(j)], ...
                    ':', 'Color', edge_color, 'LineWidth', 1.2);
            end
        end
    end
end
% Plot nodes
for i = 1:length(list)
    x = rc_center(i);
    y = dv_center(i);
    z = ml_center(i);
    region_name = list{i};
    degree = sum(adj(i, :));

    if ismember(region_name, cortex_targets)
        node_color = cortex_color_map(region_name);
        scatter3(x, y, z, 250, 'filled', ...
            'MarkerFaceColor', node_color, ...
            'MarkerEdgeColor', node_color);


    elseif ismember(region_name, listAAV)
        scatter3(x, y, z, 100, 'filled', ...
            'MarkerFaceColor', [0.8 0 0], ...
            'MarkerEdgeColor', [0.8 0 0]);



    else
        scatter3(x, y, z, 50, 'filled', ...
            'MarkerFaceColor', [0.8 0.8 0.8], ...
            'MarkerEdgeColor', 'none', 'MarkerFaceAlpha',0.4);


    end
    if ismember(region_name, cortex_targets)


        text(x, y, z +0.6, region_name, ...
            'FontSize', 22, 'FontName','Arial',  ...
            'Color', node_color, ...
            'HorizontalAlignment', 'center');

    elseif ismember(region_name, listAAV)


        text(x-0.5, y-0.2, z -0.7, region_name, ...
            'FontSize', 15, 'FontName','Arial', ...
            'Color', [0.8 0 0], ...  % grey font
            'HorizontalAlignment', 'center', 'Clipping', 'off');

    else

        text(x, y, z -0.2, region_name, ...
            'FontSize', 10, 'FontName','Arial', ...
            'Color', [0.8 0.8 0.8 0.4], ...
            'HorizontalAlignment', 'center');
    end

end

% Format
xlabel('RC (mm)');
ylabel('DV (mm)');
zlabel('ML (mm)');
% title('3D Projection of Connected Brain Regions (Pearson r > 0.7)');
grid on;
view(3);
set(gca,'FontSize',22,'FontName','Arial')
axis equal;

threshold = 0.7;  % You can adjust this
paths = {};       % to store triplets

% Loop over each AAV+ region
for i = 1:length(list)
    if ismember(list{i}, listAAV)
        src = list{i};  % AAV+ region

        for j = 1:length(list)
            tgt = list{j};

            if ismember(tgt, {'SSC', 'MC', 'VisC', 'AuC'}) && ...
                    pearson_corr(i, j) > threshold

                % Store the full path: RVLM → src → tgt
                paths{end+1, 1} = 'RVLM';
                paths{end, 2} = src;
                paths{end, 3} = tgt;
                paths{end, 4} = pearson_corr(i, j);  % add weight if needed
            end
        end
    end
end

% Display
disp('All possible RVLM → AAV+ → Cortex paths (Pearson > threshold):');
disp(paths);
%%
filename = sprintf('networkall.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);
