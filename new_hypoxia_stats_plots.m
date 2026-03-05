% === Define colors ===
colors = [0 0 0;        % Baseline - black
          0.8 0 0.8;    % Hypoxia - magenta
          0 0.7 0.8];   % Recovery - cyan
% === Output directory ===
outdir = 'E:\fiberphotometryKC\HYPOXIAPOOLDATA\jan2026_mean_subtracted_new data';
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
% Remove all-zero rows
rms_cal = rms_cal(~all(rms_cal == 0, 2), :);
mean_cal = mean_cal(~all(mean_cal == 0, 2), :);

aucldf  = aucldf(~all(aucldf == 0, 2), :);
mean_ldf = mean_ldf(~all(mean_ldf == 0, 2), :);

datasets = {mean_ldf, aucldf, rms_cal, mean_cal};
titles = {'Relative LDF', 'AUC LDF (a.u.)', 'RMS Calcium', 'Mean Calcium'};
filenames = {'Relative_LDF.pdf','AUC_LDF.pdf','RMS_Calcium.pdf', 'Mean_Calcium.eps'};

for d = 1:length(datasets)
    figure('Position', [100, 100, 400, 600]);
    data = datasets{d};

    % === Create basic boxplot ===
    boxplot(data, 'Colors', 'k', 'Labels', {'Baseline','Hypoxia','Recovery'}, ...
             'Symbol', 'k+');
    set(gca, 'XColor', 'k', 'YColor', 'k', 'FontSize', 28);
    ylabel(titles{d});
    hold on;

    % === Get boxes and recolor ===
    boxes = flipud(findobj(gca, 'Tag', 'Box'));
    nCond = min(size(colors,1), size(boxes,1));

    % Draw transparent box edges
    for j = 1:nCond
        bx = boxes(j);
        patch(get(bx,'XData'), get(bx,'YData'), 'w', ...
              'FaceAlpha', 0, 'EdgeColor', colors(j,:), 'LineWidth', 2);
    end

    % === Fix whiskers, caps, and medians based on x-position proximity ===
    allLines = findall(gca, 'Type', 'Line');
    allOutliers = findobj(gca, 'Tag', 'Outliers');
    set(allOutliers, 'Visible', 'off');

    % Get x-position for each box center
    boxCenters = cellfun(@(x) mean(x), get(boxes, 'XData'));

    for k = 1:length(allLines)
        xd = get(allLines(k), 'XData');
        xm = mean(xd);
        if ~isempty(xm) && ~any(isnan(xm))
            [~, j] = min(abs(boxCenters - xm));
            set(allLines(k), 'Color', colors(j,:), 'LineWidth', 2);
        end
    end

    hold off;

% plots the p values
stats_testjan2026
    
end
