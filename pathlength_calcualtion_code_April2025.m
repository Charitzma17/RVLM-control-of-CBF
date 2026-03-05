% Load coordinate matrix (6x25)
load('coordinates_april2025.mat');  % variable name: coordinate_limits
coordinate_limits(:,9)= mean([coordinate_limits(:,9), coordinate_limits(:,10)],2);
coordinate_limits(:,10)=[];
nregions1 = size(coordinate_limits, 2);

% RVLM reference point in mm
rvlm_coord = [-6.75, 5.9, 1.25];  % [RC, DV, ML]

% Shift all coordinates relative to RVLM
shifted_coords = coordinate_limits;
shifted_coords(1:2, :) = shifted_coords(1:2, :) - rvlm_coord(1);  % RC
shifted_coords(3:4, :) = shifted_coords(3:4, :) - rvlm_coord(2);  % DV
shifted_coords(5:6, :) = shifted_coords(5:6, :) - rvlm_coord(3);  % ML

% Initialize
region_centers = nan(nregions1, 3);     % [RC, DV, ML]
region_radii   = nan(nregions1, 3);     % semi-axes
euclidean_dist = nan(nregions1, 1);     % raw straight-line
weighted_dist  = nan(nregions1, 1);     % weighted Euclidean

% Set axis weights (tweak if needed)
% e.g., more weight to DV axis → [1 2 1]; equal weight → [1 1 1]
weights = [1, 1, 1];  

for i = 1:nregions1
    % Get shifted limits
    rc_range = shifted_coords(1:2, i);
    dv_range = shifted_coords(3:4, i);
    ml_range = shifted_coords(5:6, i);

    % Compute center (midpoint of each range)
    center = [mean(rc_range), mean(dv_range), mean(ml_range)];
    region_centers(i, :) = center;

    % Compute radii (half the extent)
    radii = [abs(diff(rc_range))/2, abs(diff(dv_range))/2, abs(diff(ml_range))/2];
    region_radii(i, :) = radii;

    % Euclidean distance from RVLM (origin)
    euclidean_dist(i) = norm(center);  % same as sqrt(sum(center.^2))

    % Weighted Euclidean distance
    weighted_dist(i) = sqrt(sum(weights .* (center.^2)));
end

% --- Optional: print sorted distances ---
[~, idx] = sort(weighted_dist);
fprintf('\nRegions sorted by Weighted Euclidean Distance from RVLM:\n');
for k = 1:nregions1
    fprintf('%2d. %s — weighted dist = %.2f mm, euclidean = %.2f mm\n', ...
        k, list{idx(k)}, weighted_dist(idx(k)), euclidean_dist(idx(k)));
end
