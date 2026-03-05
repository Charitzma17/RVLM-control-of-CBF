% idx_LC = find(strcmp(list,'LC'));
% idx_LH = find(strcmp(list,'LH'));
% idx_ZI = find(strcmp(list,'ZI'));
% idx_PAGandDR = find(strcmp(list,'PAGandDR'));
% idx_PBNandTg = find(strcmp(list,'PBNandTg'));
% idx_NTS = find(strcmp(list,'NTS'));
% idx_PCRtandIRt = find(strcmp(list,'PCRtandIRt'));
idx_MC = find(strcmp(list,'MC'));
% code to plot cell profiles for supplementary data...
% run this after main code *hsv_analysis*

idx_SSC = find(strcmp(list,'SSC'));
idx_AuC = find(strcmp(list,'AuC'));
idx_VisC = find(strcmp(list,'VisC'));

idx_regions = [idx_MC idx_SSC idx_AuC idx_VisC];
% idx_regions = [idx_LC idx_LH idx_ZI];
% idx_regions = [idx_PAGandDR idx_NTS idx_PCRtandIRt];
region_names = {'MC','SSC','AuC','VisC'};
% region_names = {'LC','LH','ZI'};
% region_names = {'PAGandDR','NTS','PCRtandIRt'};

% avg over mice, ignoring NaNs
mean_over_mice = squeeze(nanmean(avg_samp(:,:,idx_regions),2));  
% size = [ntime × 3]
% figure; hold on

% markers = {'o','s','^','d','v',''};
ntime = size(avg_samp,1);

mean_ts = zeros(ntime,3);
sem_ts  = zeros(ntime,3);

for r = 1:size(idx_regions,2)
    data = squeeze(avg_samp(:,:,idx_regions(r)));   % [ntime × nmice]
    
    mean_ts(:,r) = nanmean(data,2);
    sem_ts(:,r)  = nanstd(data,0,2) ./ sqrt(sum(~isnan(data),2));
end
figure('Position', [0, 0, 700, 700]);
hold on

% markers = {'o','s','^'};
color_arr =[0.8 0 0;...
    0 0.8 0;...
    0 0 0.8;...
    0.6 0.6 0;...
    0 0.6 0.6;...
    0 0 0;...
    0.5 0.5 0.5;...
    0.6 0 0.6];
for r = 1:size(idx_regions,2)
    errorbar(1:ntime, mean_ts(:,r), sem_ts(:,r), ...
        'o-', ...
        'Color',color_arr(r,:),...
        'LineWidth',2, ...
        'MarkerSize',15, ...
        'CapSize',10);
end
xticks(1:4)
xticklabels({'36h','48h','60h','72h'})
xlabel('Time post injection');
ylabel('Mean number of cells/mouse');
l = legend(region_names,'Location','best');
l.Box = 'off';
l.Location = 'northwest';
set(gca,'FontSize',22)
% title('LC, LH, and ZI (mean ± SEM across mice)');
box off;





