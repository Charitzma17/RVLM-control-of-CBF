% CODE to plot a swarm plot showing distribution of projections from AAV tracing throughout the brain
% INPUTS:
% numel_pix: [n_mice x n_areas x n_sections]
% listofareas: {'L.MRN', 'R.MRN', ..., 'PVH', 'PO'} etc.

[n_mice, n_areas, n_sections] = size(numel_pix);
base_names = regexprep(listofareas, '^[LR]\.', '');
[unique_bases, ~, idx_map] = unique(base_names);
area_data = struct();

for i = 1:length(unique_bases)
    base = unique_bases{i};
    area_idxs = find(idx_map == i);  % L. and/or R. indices

    if numel(area_idxs) == 2
        % Both L and R exist
        idL = area_idxs(1);
        idR = area_idxs(2);
        
        % Get data: [mice x sections]
        dataL = squeeze(numel_pix(:, idL, :));  % [mice x secL]
        dataR = squeeze(numel_pix(:, idR, :));  % [mice x secR]
        
        % Determine # of sections
        validL = any(dataL > 0, 1);  % which sections exist
        validR = any(dataR > 0, 1);
        secL = sum(validL);
        secR = sum(validR);
        
        % Align: fold L into R (assume secR >= secL)
        m = secR;
        merged = nan(n_mice, m);
        merged(:, 1:secR) = dataR(:, 1:secR);
        merged(:, 1:secL) = merged(:, 1:secL) + dataL(:, 1:secL);

        % Store
        area_data.(base) = merged(:);  % flatten for violin
    else
        % Only one side exists (e.g., midline or already merged)
        data = squeeze(numel_pix(:, area_idxs, :));
        data = data(:);
        area_data.(base) = data(~isnan(data) & data > 0);
    end
end

area_names = fieldnames(area_data);
n_areas = numel(area_names);
% define colors

colors_areas= [
    1.0000, 0.6000, 0.0000;   % Orange
    1.0000, 0.8500, 0.0000;   % Golden Yellow
    0.8500, 1.0000, 0.0000;   % Yellow-Green
    0.6000, 1.0000, 0.2000;   % Spring Green
    0.3000, 1.0000, 0.5000;   % Mint Green
    0.0000, 1.0000, 0.8000;   % Aqua
    0.0000, 0.8500, 1.0000;   % Cyan
    0.0000, 0.6000, 1.0000;   % Sky Blue
    0.0000, 0.3000, 1.0000;   % Blue
    0.2000, 0.0000, 1.0000;   % Indigo
    0.5000, 0.0000, 1.0000;   % Violet
    0.7000, 0.0000, 1.0000;   % Deep Purple
    0.8000, 0.0000, 0.6000;   % Rose Magenta
    1.0000, 0.0000, 1.0000;   % Pink-Magenta
];
% rostrocaudal order
desired_order = { ...
    'AP', 'NTS', 'PCRtandIRt', 'LC', 'PAGandDR', ...
    'PBNandTg', 'MRN', 'VTA', 'ZI', 'LH', ...
    'PVH', 'PVT', 'STandseptum', 'PO'};

% Create figure
fig = figure('Color', 'w', 'Position', [100, 100, 1200, 500]);
hold on;

all_vals = [];
kde_scale = 0.45;

for i = 1:length(desired_order)
    area_name = desired_order{i};

    if ~isfield(area_data, area_name)
        warning('Area "%s" not found in area_data.', area_name);
        continue;
    end

    vals = area_data.(area_name);
    vals = vals(vals > 0);  % Exclude zeros

    if isempty(vals), continue; end
    all_vals = [all_vals; vals];

   

    % 📈 KDE for violin
    [f, xi] = ksdensity(vals, 'Support', 'positive','BandWidth', 0.2);
    f = f / max(f);  % normalize
    x_left  = i - kde_scale * f;
    x_right = i + kde_scale * f;

     fill([i - kde_scale *f, fliplr(i + kde_scale *f)], [xi, fliplr(xi)], colors_areas(i, :), ...
        'FaceAlpha', 0.7, 'EdgeColor', 'none');
      % 🐝 Swarm
    swarmchart(...
        repmat(i, size(vals)), vals, ...
        20, 'k', 'filled', ...
        'MarkerFaceAlpha', 1, ...
        'XJitter', 'rand', ...
        'XJitterWidth', 0.3 ...
    );
end

% Axes styling
set(gca, ...
    'XTick', 1:length(desired_order), ...
    'XTickLabel', desired_order, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 24, ...
    'Box', 'off');

ylabel('#Pixels ', 'FontSize', 24);

% Clean Y-limits
ylim([0, max(all_vals) * 1.5]);
outdir = 'Z:\Karishma\aavdata_store_may2025';

filename = sprintf('sectionpixels.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);
%% Fractional pixel calculation
% Copy original
numel_pix_cleaned = numel_pix;

% Area parsing
area_names_noprefix = regexprep(listofareas, '^[LR]\.', '');
[unique_bases, ~, idx_map] = unique(area_names_noprefix);

% Special areas for correction
cvlm_idx = find(strcmpi(area_names_noprefix, 'CVLM'));
sfo_idx  = find(strcmpi(area_names_noprefix, 'SFO'));
pvt_idx  = find(strcmpi(area_names_noprefix, 'PVT'));

% Remove CVLM as cant define it clearly to injection site labelling
numel_pix_cleaned(:, cvlm_idx, :) = NaN;

% Add SFO into PVT since SFO was mislabelled as PVT for some sections
for m = 1:n_mice
    for i = 1:numel(pvt_idx)
        sfo_match = sfo_idx(mod(i-1, numel(sfo_idx)) + 1);  % match L to L, R to R
        pvt_vals = squeeze(numel_pix_cleaned(m, pvt_idx(i), :));
        sfo_vals = squeeze(numel_pix_cleaned(m, sfo_match, :));
        combined = nansum(cat(2, pvt_vals, sfo_vals), 2);
        numel_pix_cleaned(m, pvt_idx(i), :) = combined;
        numel_pix_cleaned(m, sfo_match, :) = NaN;
    end
end
frac_pix = nan(size(numel_pix));

for m = 1:n_mice
    total_pix = sum(numel_pix_cleaned(m, :, :), 'all', 'omitnan');
    if total_pix > 0
        frac_pix(m, :, :) = numel_pix(m, :, :) / total_pix;
    end
end

area_data_frac_pix = struct();

for i = 1:length(unique_bases)
    base = unique_bases{i};
    area_idxs = find(idx_map == i);

    merged_vals_all_mice = [];

    for m = 1:n_mice
        if numel(area_idxs) == 2
            idL = area_idxs(1);
            idR = area_idxs(2);

            vals_L = squeeze(frac_pix(m, idL, :)); vals_L = vals_L(:);
            vals_R = squeeze(frac_pix(m, idR, :)); vals_R = vals_R(:);

            valid_L = vals_L > 0;
            valid_R = vals_R > 0;
            n_L = sum(valid_L);
            n_R = sum(valid_R);

            if n_L == 0 && n_R == 0
                merged = [];
            elseif n_L == 0
                merged = vals_R(valid_R);
            elseif n_R == 0
                merged = vals_L(valid_L);
            else
                if n_L >= n_R
                    merged = vals_L(valid_L);
                    merged(1:n_R) = mean([merged(1:n_R), vals_R(valid_R)], 2, 'omitnan');
                else
                    merged = vals_R(valid_R);
                    merged(1:n_L) = mean([merged(1:n_L), vals_L(valid_L)], 2, 'omitnan');
                end
            end
        else
            % Only one side exists
            id = area_idxs;
            vals = squeeze(frac_pix(m, id, :)); vals = vals(:);
            merged = vals(vals > 0);
        end

        merged_vals_all_mice = [merged_vals_all_mice; merged(:)];
    end

    area_data_frac_pix.(base) = merged_vals_all_mice;
end
desired_order = { ...
    'AP', 'NTS', 'PCRtandIRt', 'LC', 'PAGandDR', ...
    'PBNandTg', 'MRN', 'VTA', 'ZI', 'LH', ...
    'PVH', 'PVT', 'STandseptum', 'PO'};

figure('Color', 'w', 'Position', [100, 100, 1600, 800]);
hold on;

all_vals = [];
kde_scale = 0.4;

for i = 1:length(desired_order)
    area_name = desired_order{i};

    if ~isfield(area_data_frac_pix, area_name)
        warning('Area "%s" not found.', area_name);
        continue;
    end

    vals = area_data_frac_pix.(area_name);
    vals = vals(vals > 0);  % remove zeros

    if isempty(vals), continue; end
    all_vals = [all_vals; vals];

    % Swarm
    swarmchart(...
        repmat(i, size(vals)), vals, ...
        10, 'k', 'filled', ...
        'MarkerFaceAlpha', 0.3, ...
        'XJitter', 'rand', ...
        'XJitterWidth', 0.4 ...
    );

    % KDE Violin
    [f, xi] = ksdensity(vals, 'Support', 'positive', 'Bandwidth', 0.08);
    f = f / max(f);  % normalize

    x_left  = i - kde_scale * f;
    x_right = i + kde_scale * f;

    fill([x_left, fliplr(x_right)], [xi, fliplr(xi)], ...
         [0.8 0.8 0.8], ...
         'FaceAlpha', 0.5, ...
         'EdgeColor', 'k', ...
         'LineWidth', 1);
end

set(gca, ...
    'XTick', 1:length(desired_order), ...
    'XTickLabel', desired_order, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 28, ...
    'Box', 'off');

ylabel('Fraction of White Pixels (L+R folded)', 'FontSize', 28);
title('Fractional Pixel Count: Violin + Swarm Plot per Area', 'FontSize', 32);
ylim([0, max(all_vals) * 1.1]);



