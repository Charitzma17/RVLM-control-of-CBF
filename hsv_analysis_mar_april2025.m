% code to plot a grid of the projections across time with predicted network
% structure based on AAV and centrality data
%% make note of the flipped matrices due to either Agnies or me mounting:
% 2.5dpiF1, 2dpi f2 and f3, 1.5 m3 and m6 -flipped

clearvars
% close all
clc


% loading section...

% 1_5dpi
load M3_1_5dpinew.mat;
tp1_1= M3_1_5dpi;% timepoint 1 dataset 1

load M6_1_5dpinew.mat
tp1_2 = M6_1_5dpi;

load M2_1_5dpi_oct23new.mat
tp1_3 = M2_1_5dpioct23;

% 2dpi
load F2_MayJun23_2dpinew.mat;
tp2_1 = F2_MayJun23_2dpi;

load F3_MayJun23_2dpinew.mat;
tp2_2 = F3_MayJun23_2dpi;

load F1_MayJun23_2dpinew.mat;
tp2_3= F1_MayJun23_2dpi;


%2.5dpi
load F3_2_5dpinew.mat;
tp3_1 = F3_2_5dpi;

load F1_2_5dpinew.mat;
tp3_2 = F1_2_5dpi;

load M2_2_5dpi_oct23new.mat;
tp3_3 = M2_2_5dpioct23;


%3dpi
load F1_Mar23_3dpinew.mat;
tp4_1 = F1_Mar23_3dpi;

load F2_Mar23_3dpinew.mat;
tp4_2 =  F2_Mar23_3dpi;

load May23_3_5dpinew.mat;
tp4_3 = May23_3_5_dpi;

load F2_Jan23_3dpinew.mat;
tp4_4 = F2_Jan23_3dpi;

% centrality
%%

str_siz = 100;

list={'NTS';...
    'Hypoglossalnuc';...
    'PCRtandIRt';...
    'Sp5';...
    'Gi';...
    'Vestibularnuc';...
    'LC';...
    'Supratrigeminalnuc';...
    'PAGandDR';...
    'PBNandTg';...
    'SNR';...
    'ZI';...
    'VTA';...
    'PVH';...
    'LH';...
    'Hippocampus';...
    'VisC';...
    'AuC';...
    'SSC';...
    'MC';...
    'PVT';...
    'PO';...
    'Amg';...
    'IC';};
load 'volume calculated_forplots.mat';
load 'rostrocaudallimits_ofareas.mat';

%calculating reference path length of different areas from rvlm to show the
%estimated distance travelled
rvlmref = -6.75;% mm from bregma
up_rcref = rostrocaud_Area_pt(1,:)-rvlmref;
low_rcref = rostrocaud_Area_pt(2,:)-rvlmref;
pathlength = (up_rcref+low_rcref)./2;

%

volume_mm = volume_calculated./(1000)^3;
mouse_arr = [2,3,2,4]; %number of mice I have from different timepoints
% flip_arr = [1,1;1,2;2,1;2,2;3,2];

flp_arr = ['1n1';'1n2';'2n1';'2n2';'3n2'];




%% for avg for 3dpi all mice


Color_arr = [0.9 0.7 0.7;...
    0.7 0.9 0.7;...
    0.7 0.7 0.9;...
    0.9 0.7 0.9];

% for time points comparison
color_arr2 = [0.9 0 0.9;...
    0 0.9 0;...
    0 0 0.9;...
    0.9 0 0];

% for time points comparison
color_arr3 = [0.9 0.6 0.9;...
    0.6 0.9 0.6;...
    0.6 0.6 0.9;...
    0.9 0.6 0.6];
nummice_arr = [3,3,3,4];
for tp = 1:4
    nummice = nummice_arr (tp);
    for mouse = 1:nummice% num of 3dpi mice
        file_name = strcat('tp',num2str(tp,'%2d'),'_',num2str(mouse,'%2d'));
        temp = eval(file_name);
        % below is summing the ipsi and contralateral
        % tot_cels = sum(temp(:));
        NTS = temp(:,1)+ temp(:,14)+ sum(temp(:,17:18),2);
        Hypoglossalnuc = temp(:,2);
        PCRtandIRt = sum(temp(:,3:4),2);
        Sp5 = sum(temp(:,7:8),2);
        Gi = sum(temp(:,12:13),2);
        Vestibularnuc = sum(temp(:,15:16),2);
        LC = sum(temp(:,20:21),2);
        Supratrigeminalnuc = sum(temp(:,22:23),2);
        PAGandDR = temp(:,24);
        PBNandTg =sum(temp(:,25:27),2);
        SNR = sum(temp(:,30:31),2);
        ZI = sum(temp(:,32:33),2);
        VTA = sum(temp(:,34:35),2);
        PVH = temp(:,36);
        LH = sum(temp(:,37:38),2);
        Hippocampus = temp(:,39);
        VisC = sum(temp(:,40:41),2);
        AuC = sum(temp(:,42:43),2);
        SSC = sum(temp(:,44:45),2);
        MC = sum(temp(:,46:47),2);
        PVT = temp(:,48);
        PO = temp(:,49);
        Amg = sum(temp(:,50:51),2);
        IC = sum(temp(:,52:53),2);
        
        all=[NTS,Hypoglossalnuc,PCRtandIRt,Sp5,Gi,Vestibularnuc,LC,Supratrigeminalnuc,PAGandDR,PBNandTg,SNR,ZI,VTA,PVH,LH,Hippocampus,VisC,AuC,SSC,MC,PVT,PO,Amg,IC];
        total_cells = sum(all(:));% total cells per mouse per time point
        % alltps(tp,mouse,:) = all;
        for k =1:24% num of regions
            samp = eval(list{k});
            plot_samp = samp;
            plot_samp(plot_samp==0)=[];
            num_slice = numel(plot_samp(plot_samp~=0));
            if (plot_samp)
                
                avg_samp(tp,mouse,k) = sum(plot_samp);% fractional labelling per region per mouse

            else % else loop only for not 3dpi as the projections can be zero
                avg_samp(tp,mouse,k) = 0;

            end
        end


    end
end
% Dimensions
[ntime, nmice_max, nregions] = size(avg_samp);
fractional_data = nan(size(avg_samp)); % same size
time_labels = {'36h', '48h', '60h', '72h'};

for t = 1:ntime
    for m = 1:nmice_max
        region_counts = squeeze(avg_samp(t, m, :));
        total_cells = sum(region_counts, 'omitnan');
        if total_cells > 0
            fractional_data(t, m, :) = region_counts / total_cells;
        end
    end
end
figure('Position', [100, 100, 1500, 600]);
hold on;

for t = 1:ntime
    data = squeeze(fractional_data(t, :, :)); % [mouse x region]
    means = mean(data, 1, 'omitnan');
    sems = std(data, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(data), 1));

    % X = regions
   errorbar(1:nregions, means, sems, ...
        'LineWidth', 2.5, ...
        'Color', color_arr2(t,:), ...
        'CapSize', 8, ...
         'Marker', 'o', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', color_arr2(t,:), ...
        'DisplayName', time_labels{t});

end

xticks(1:nregions);
xticklabels(list);  % 👈 Again, real region names here
xtickangle(45);
ylabel('% #Cells/section');
title('Regional Labeling Over Time');
legend('Location', 'northeast');
set(gca,'FontSize',28)
grid on;
hold off;


%% Assumes avg_samp: [4 timepoints x up to 4 mice x 25 regions]
% Assumes list: 1x25 cell array of region names

[ntime, nmice, nregions] = size(avg_samp);
all_data = [];         % Final matrix [N_valid_mice x regions]
row_labels = {};       % Y-axis labels for animals with data

for t = 1:ntime
    for m = 1:nmice
        this_row = squeeze(avg_samp(t, m, :))'; % [1 x nregions]
        if any(this_row > 0)  % Only keep rows with at least one non-zero count
            all_data = [all_data; this_row];
            row_labels{end+1} = sprintf('T%d-M%d', t, m);
        end
    end
end

% Optional: replace remaining NaNs (if any) with 0
all_data(isnan(all_data)) = 0;

% Plotting
figure('Position', [0, 0, 350, 700]);

imagesc(log10(all_data'));
colormap(slanCM(45))
cb = colorbar;                       % Adds colorbar to current axes
cb.Location = 'eastoutside';            % Below all subplots


% xlabel('Brain Regions');
% ylabel('Animal (Timepoint + Mouse)');
% title('Labeling Across Mice and Timepoints');
set(gca,'FontSize',14,'FontName','Arial')
yticks(1:nregions);
yticklabels(list);
ytickangle(45)

% yticks(1:size(all_data, 1));
% yticklabels(row_labels);
xticks manual

outdir = 'E:\HSV_analysis\manual_cellcount_analysis\september_2025_figs';

filename = sprintf('allcells.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);

% avg_samp: [ntime x nmice x nregions]
[ntime, nmice, nregions] = size(avg_samp);
region_labels = list;  % Your 25 region names
color_arr3 = [0.9 0.6 0.9;    % 36h
              0.6 0.9 0.6;    % 48h
              0.6 0.6 0.9;    % 60h
              0.9 0.6 0.6];   % 72h
time_labels = {'36h', '48h', '60h', '72h'};

% Precompute fractional data + y-axis limit
all_frac_data = nan(ntime, nmice, nregions);
max_y = 0;
% fraction of cells calculation...
for t = 1:ntime
    for m = 1:nmice
        this_mouse = squeeze(avg_samp(t, m, :))';
        total_cells = sum(this_mouse, 'omitnan');
        if total_cells > 0
            frac = this_mouse./total_cells ;
            all_frac_data(t, m, :) = frac;
            max_y = max(max_y, max(frac, [], 'omitnan'));
        end
    end
end

% Use tiled layout for tight control
figure('Position', [0, 0, 640, 700]);
tiledlayout(4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

for t = 1:ntime
    nexttile; hold on;
    
    frac_per_mouse = squeeze(all_frac_data(t, :, :)); % [mice x regions]
    mean_frac = mean(frac_per_mouse, 1, 'omitnan');
    sem_frac  = std(frac_per_mouse, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(frac_per_mouse), 1));
    
    % Bar plot
    bar(mean_frac, 'FaceColor', color_arr3(t,:), 'EdgeColor', 'none');
    
    % Scatter individual mice
    for r = 1:nregions
        for m = 1:nmice
            val = frac_per_mouse(m, r);
            if ~isnan(val)
                scatter(r, val, 25, 'k', 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none');
            end
        end
    end
    
    % Error bars
    errorbar(1:nregions, mean_frac, sem_frac, 'k.', 'LineWidth', 1);

    % Axes
    xticks(1:nregions);
    ylim([0 max_y * 1.1]);
    % ylabel('Fraction');
    
    if t == ntime
        xticklabels(region_labels);
        xtickangle(45);
    else
        xticklabels([]);
    end
        
    % Label for timepoint
    text(1, max_y * 1.05, time_labels{t}, 'FontWeight', 'bold', 'FontSize',12,'FontName','Arial');
    grid on; box off;
    set(gca,'FontSize',12,'FontName','Arial')
end
filename = sprintf('fractioncellshistogram.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);
% sgtitle('Fractional Labeling per Region Across Timepoints');
%% slope of change of cells april 6th 2025
listAAV ={'NTS';...
    'PCRtandIRt';...
    'LC';...
    'PAGandDR';...
    'PBNandTg';...
    'ZI';...
    'LH';...
    'PVH';...
    'PVT';...
    'PO';};
for r = 1:nregions
    mean_cell_slopes(1,r) = 0;% first time assumption as 0 cells
    temp_t1 = squeeze(avg_samp(1,:,r));% number of cells in region r at time t-1
    mean_cell_slopes(2,r) = mean(temp_t1)./36; % first time point is 36h
    for t = 2:4
        temp_t1 = squeeze(avg_samp(t-1,:,r));% number of cells in region r at time t-1
        temp_t2 = squeeze(avg_samp(t,:,r));% number of cells in region r at time t
        mean_cell_slopes(t+1,r) = (mean(temp_t2)-mean(temp_t1))./12;
    end
    plot([1:5],mean_cell_slopes(:,r));% total time points 5 including the time point 0
    set(gca,'FontSize',22,'Fontweight','bold')
    % pause
    hold on;
end
legend(list);

% code for the pathlenght call here april 2025

pathlength_calcualtion_code_April2025;
% compare euclid with change in cells


% Assume:
% mean_cell_slopes: [3 x 25]
% pathlengths: [25 x 1]  (Euclidean or weighted)
% list: 1x25 cell array with region names



time_labels = {'T0','T1-T0','T2–T1', 'T3–T2', 'T4–T3'};
% Logical index of regions in listAAV
isAAV = ismember(list, listAAV);

figure('Position', [0, 0, 1100, 800]);
hold on;

for t = 2:5
    scatter(weighted_dist, mean_cell_slopes(t, :), ...
        500, color_arr2(t-1,:), 'filled', ...
        'DisplayName', time_labels{t}, ...
        'MarkerFaceAlpha', 1);
     % Highlight known AAV efferent regions
    scatter(weighted_dist(isAAV), mean_cell_slopes(t, isAAV), ...
        100, 'yellow','filled', ...
       'o');
    
    if t == 5
        for r = 1:length(region_labels)
            if ismember(r,[2,6,14,12])
                text(weighted_dist(r) + 0.05, mean_cell_slopes(t, r), region_labels{r}, ...
                    'FontSize', 14, 'FontWeight','bold','Color', 'k', 'HorizontalAlignment', 'right');
            else
                text(weighted_dist(r) + 0.05, mean_cell_slopes(t, r), region_labels{r}, ...
                    'FontSize', 14,'FontWeight','bold', 'Color', 'k', 'HorizontalAlignment', 'left');
            end
        end
    end
end
xlabel('Pathlength from RVLM (mm)');
ylabel('Mean \Delta Cells/hr');
% legend('Location', 'northeast');
grid on;
set(gca, 'FontSize', 24);

%% add centrality for a 3d plot

centrality;

filename = sprintf('centrality.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 400);
fprintf('Exported %s\n', fullpath);

%% 2d plot between centrality and mean cell slope
% Step 1: Indices for AAV+ regions
idxAAV = find(ismember(list, listAAV));  % index of AAV+ regions

% Step 2: Extract relevant data
pathlengths_AAV = euclidean_dist(idxAAV);   % X-axis
centrality = sum(in_out, 2);            % Y-axis (you provide this)
slopes_AAV = mean_cell_slopes(:, idxAAV);   % Z-axis: [3 x nAAV]

% Plot settings
colors = [0.8 0.4 0.9; 0.4 0.8 0.6; 0.4 0.6 0.9];

% Plot
figure('Position', [0, 0, 1500, 800]); hold on;

for t = 2:5
    scatter(pathlengths_AAV, slopes_AAV(t, :), ...
        400, color_arr2(t-1,:), 'filled', ...
        'DisplayName', time_labels{t}, ...
        'MarkerFaceAlpha', 0.7);

 
    if t ==5
        for i = 1:length(idxAAV)

            x = pathlengths_AAV(i);
            y = centrality(i);
            z = slopes_AAV(t, i);

            % Region name (larger font)
            text(x + 0.2, y, listAAV{i}, ...
                'FontSize', 18, 'FontWeight', 'bold', ...
                'Color', [0.2 0.2 0.2], ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'bottom');

            % % Coordinates (smaller font, slightly lower in z)
            % text(x + 0.2, y, z - 0.3, ...
            %     sprintf('(%.0f, %.0f, %.0f)', x, y, z), ...
            %     'FontSize', 10, ...
            %     'Color', [0.3 0.3 0.3], ...
            %     'HorizontalAlignment', 'left', ...
            %     'VerticalAlignment', 'top');
        end
    end
end

% Axis labels, title, etc.
% Axes and labels
ylabel('Centrality');
zlabel('Mean \Deltacells/hr');
xlabel('Pathlength from RVLM (mm)');

legend('Location', 'northeast');
grid on;
view(45, 30);
set(gca, 'FontSize', 24);


%% correlation plots and adjacency and predictions....
% Assume mean_cell_slopes is [5 x 25]
[num_timepoints, num_regions] = size(mean_cell_slopes);

% Step 1: Rank each region’s time series (across time)
ranks = zeros(size(mean_cell_slopes));  % same size as original

for r = 1:num_regions
    x = mean_cell_slopes(:, r);  % time series for region r

    % Rank x manually
    [~, order] = sort(x);
    [~, rank] = sort(order);
    ranks(:, r) = rank;
end

% % Step 2: Compute Pearson correlation on the ranked data
% spearman_corr = zeros(num_regions);
% 
% for i = 1:num_regions
%     for j = 1:num_regions
%         xi = ranks(:, i);
%         yj = ranks(:, j);
% 
%         % Mean subtraction
%         xi = xi - mean(xi);
%         yj = yj - mean(yj);
% 
%         % Pearson on ranks
%         numerator = sum(xi .* yj);
%         denominator = sqrt(sum(xi.^2) * sum(yj.^2));
% 
%         spearman_corr(i, j) = numerator / denominator;
%     end
% end
% Step 1: Center and normalize slope data
X = mean_cell_slopes';  % [regions x timepoints]
X_centered = X - mean(X, 2);

% Step 2: Pearson correlation between regions
num_regions = size(X,1);
pearson_corr = zeros(num_regions);

for i = 1:num_regions
    for j = 1:num_regions
        xi = X_centered(i,:);
        yj = X_centered(j,:);
        pearson_corr(i,j) = dot(xi, yj) / (norm(xi) * norm(yj));
    end
end
% Step 3: Plot
figure;
imagesc(pearson_corr);
colormap(gray);
colorbar;
axis square;

xticks(1:num_regions);
yticks(1:num_regions);
xticklabels(list);
yticklabels(list);
xtickangle(45);
% title('Spearman Correlation of Labeling Slopes Across Regions');
set(gca, 'FontSize', 10, 'FontWeight', 'bold','FontName','Arial');

% Step 1: Convert Spearman correlation to a distance matrix
dist_mat = 1 - abs(pearson_corr);

% Linkage for dendrogram
Z = linkage(dist_mat, 'complete');

% Step 3: Get dendrogram order
[H, T, outperm] = dendrogram(Z, 0);  % outperm = leaf order

% Assign flt clusters
cutoff = 0.7;  % adjust this as needed
Clust = cluster(Z, 'Cutoff', cutoff, 'Criterion', 'distance');

% --- Step 3: Reorder Data ---
[~, sort_idx] = sort(Clust);  % order by cluster
R_sorted = pearson_corr(sort_idx, sort_idx);
list_sorted = list(sort_idx);
Clust_sorted = Clust(sort_idx);
close all
% --- Step 4: Plot Sorted Matrix with Cluster Coloring ---
figure('Position', [0, 0, 800, 600]);
% R_vis = 2 ./ (1 + exp(-3*R_sorted)) - 1;
% R_vis = sign(R_sorted).*(-log(1-abs(R_sorted)));
eps_clip = 1e-6;
Rz = R_sorted;
% process for visualization using fischer z transform
Rz(Rz>=1)=1-eps_clip;
Rz(Rz<=-1)= -1+eps_clip;
Z1= atanh(Rz);
Zz = (Z1-mean(Z1(:)))./std(Z1(:));
lo = prctile(Zz(:),1);
hi = prctile(Zz(:),99);
Zz_disp = min(max(Zz,lo),hi);
imagesc(Zz_disp);


% hold on;
% 
% cl = Clust_sorted(:);
% n  = numel(cl);
% 
% % Boundaries where cluster ID changes in the sorted order
% b = [0; find(diff(cl) ~= 0); n];
% 
% for k = 1:numel(b)-1
%     i1 = b(k)+1;
%     i2 = b(k+1);
%     w  = i2 - i1 + 1;
% 
%     % Draw outlines only for clusters with >= 2 items
%     if w >= 2
%         rectangle('Position',[i1-0.5, i1-0.5, w, w], ...
%                   'EdgeColor','k', 'LineWidth',2);
%     end
% end
% 
% hold off;


% colormap(gray);
% colormap(slanCM(98));%3, 39, 58 86
colormap(redblue(40))
colorbar;
axis square;
caxis([-1 1]); % instead of [-1 1]
xticks(1:num_regions);
yticks(1:num_regions);
xticklabels(list_sorted);
yticklabels(list_sorted);
xtickangle(45);

% title('Clustered Spearman Correlation of Labeling Slopes');
set(gca, 'FontSize', 12,'FontWeight','Bold');
filename = sprintf('correlationmatrix.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 400);
fprintf('Exported %s\n', fullpath);
%
network_estimated_plot_april2025;

% --- Optional: Show Cluster Boundaries ---
% hold on;
% boundaries = find(diff(Clust_sorted));
% for b = boundaries
%     xline(b + 0.5, '--k', 'LineWidth', 1);
%     yline(b + 0.5, '--k', 'LineWidth', 1);
% end
cutoffs = 0.1:0.05:0.9;
n_clusters = zeros(size(cutoffs));

for i = 1:length(cutoffs)
    
    Clust = cluster(Z, 'Cutoff', cutoffs(i), 'Criterion', 'distance');
    n_clusters(i) = length(unique(Clust));
end

plot(cutoffs, n_clusters, '-o');
xlabel('Cutoff Value');
ylabel('Number of Clusters');
title('Choosing a Cutoff for Clustering');
grid on;
