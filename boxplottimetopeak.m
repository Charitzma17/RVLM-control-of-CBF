% --- Input arrays ---
% top_ecog and top_ldf: n_mice x n_trials (zeros = missing trials)

% Replace zeros with NaN so they're ignored
ecog = topecog(1:3)./Fs;
ldf  = topldf(1:3)./Fs;

% Combine into one long vector for boxplot
vals = [ecog(:); ldf(:)];
groups = [repmat({'ECoG'}, numel(ecog), 1); repmat({'LDF'}, numel(ldf), 1)];

% Remove NaNs
validIdx = ~isnan(vals);
vals = vals(validIdx);
groups = groups(validIdx);

% --- Boxplot ---
figure; hold on;
boxplot(vals, groups, ...
    'Colors', 'k', ...                     % black box edges
    'Symbol', '', ...                      % remove outlier symbols
    'Widths', 0.4, ...                     % thinner boxes
    'MedianStyle', 'target');              % clean median line

% Get box handles to recolor faces gray
h = findobj(gca, 'Tag', 'Box');
for j = 1:length(h)
    patch(get(h(j), 'XData'), get(h(j), 'YData'), [0.9 0.9 0.9], ...
          'FaceAlpha', 0.8, 'EdgeColor', 'k');
end

% --- Overlay scatter points ---
xJitter = 0.2;
x_ecog = 1 + (rand(sum(~isnan(ecog(:))),1) - 0.5)*xJitter;
x_ldf  = 2 + (rand(sum(~isnan(ldf(:))),1) - 0.5)*xJitter;

scatter(x_ecog, ecog(~isnan(ecog)), 100, 'b', 'filled', 'MarkerFaceAlpha', 0.8);
scatter(x_ldf,  ldf(~isnan(ldf)),  100, 'r', 'filled', 'MarkerFaceAlpha', 0.8);

% --- Aesthetics ---
set(gca, 'XTick', [1 2], 'XTickLabel', {'ECoG', 'LDF'}, 'FontSize', 24);
ylabel('Time to Peak (s)');
ylim([2.5 3.5])
xlim([0.75 2.25])
set(gcf,'units','points','position',[900,100,450,500])

% title('Top Time to Peak: ECoG vs LDF');
box off;

outdir = 'X:\kchhabria\eeg_ldff_data\sep15_2025_biphassic_data';
filename = sprintf('timetopeak.pdf');
fullpath = fullfile(outdir, filename);
set(gcf,'Renderer','opengl')
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);