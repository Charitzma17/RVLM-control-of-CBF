%% code to plot scatter between auc and peakvsd for all dreadds
% july 9th 2024

clearvars
close all

load LCall_9vessels_july15th2024.mat
vsd1 = vsd_tr;
auc1 = auc_tr;
peakvsd1 = peakvsd_tr;



load ZIdreadds_allvesselsn0f7_july16th2024.mat
vsd2 = vsd_tr;
auc2 = auc_tr;
peakvsd2 = peakvsd_tr;



% load doubledreadds_all6animals_july8th2024.mat
load doubledreadds_al8animals_oct8th2024.mat
vsd3 = vsd_tr;
auc3 = auc_tr;
peakvsd3 = peakvsd_tr;




%% for the scatter plot of all positives
%compared to the saline
close all
outdir = 'E:\2P_w_Pantong_ChR_RVLM\Data_KC\dreadds_LC_Zi_processing_data_sep2023\figures_september23rd_2025';



colorray = [0.8 0 0;
    0 0.8 0.;
    0 0 0];
figure('Position', [0, 0, 720, 550]); hold on;

for j = 1:3
    % figure(1),
    filename1 = strcat('peakvsd',num2str(j,'%2d'));
    temp0 = eval(filename1);

    filename2 = strcat('auc',num2str(j,'%2d'));
    temp00 = eval(filename2);
    array = cell2mat(arr(j));
    clear mean_temp2 mean_temp22
    for con = 1:2
        temp1 = squeeze(temp0(con,array,:));
        temp11 = squeeze(temp00(con,array,:));

        for k = 1:size(temp1,1)
            temp2 = temp1(k,:);
            temp2 = temp2(temp2~=0);
            mean_temp2(con,k) = mean(temp2);

            temp22 = temp11(k,:);
            temp22 = temp22(temp22~=0);
            mean_temp22(con,k) = mean(temp22);
        end
    end
    mean_diff2 = mean_temp2(2,:)-mean_temp2(1,:);
    mean_diff22 = mean_temp22(2,:)-mean_temp22(1,:);
    if j==1
        lcpkvsd = mean(mean_diff2(:));
        lcauc = mean(mean_diff22(:));
    elseif j ==2
        zivsd = mean(mean_diff2(:));
        ziauc = mean(mean_diff22(:));
    elseif j ==3
        sum_mean1 = lcpkvsd+zivsd;
        sum_mean2 = lcauc+ziauc;
        predicted_bothvsd1 = sum_mean1;
        predicted_bothauc2 = sum_mean2;
        actual_bothvsd1 = mean(mean_diff2(:));
        actual_bothauc2 = mean(mean_diff22(:));
    end

    % regression line jan 2026

    if j ==1
        x = mean_diff22;
        y = mean_diff2;
    else
        x = [x,mean_diff22];
        y = [y,mean_diff2];
    end
    s2 = scatter(mean_diff22,mean_diff2,'filled');
    s2.SizeData=500;
    s2.MarkerFaceColor = colorray(j,:);%[0.9 0.4 0.4];
    set(gca,'FontSize', 24);

    ylabel('\DeltaPeakVSD')
    xlabel('\DeltaAUC')
    grid on; box on;
    hold on;

end
p = polyfit(x,y,1);
yfit = polyval(p,x);
[xs,idx] = sort(x);
plot(xs,yfit(idx),'k-')

filename = sprintf(strcat('scatter','.pdf'));
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);

%% boxplots!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Color_code=[0 0.6 0.9;
    0.7 0 0.5;
    0 0 0;];

for ki = 1:3% 3 sets of conditions
    filename1 = strcat('auc',num2str(ki,'%2d'));% change to whichever variable you want to plot amongst the peakvsd, vsd and auc
    temp0 = eval(filename1);

    array = cell2mat(arr(ki));
    clear mean_temp2



    figure()
    for con = 1:3
        temp1 = squeeze(temp0(con,array,:));
        for k = 1:size(temp1,1) % k is the number of animals
            temp2 = temp1(k,:);
            temp2 = temp2(temp2~=0);
            mean_temp2(con,k) = mean(temp2);
        end


        scatter(con,mean_temp2(con,:),100,'filled','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);
        hold on;

    end
    %


    x1 = 1:3;
    boxplot(mean_temp2', x1, ...
        'Widths', 0.5, ...            % Width of the box plots
        'Whisker', 2, ...           % Whisker length (1.5 times the IQR)
        'Colors', Color_code, ...     % Outline colors
        'Symbol', 'r+', ...           % Symbol for outliers
        'OutlierSize', 6, ...         % Size of outlier markers
        'MedianStyle', 'line', ...    % Style of the median line
        'BoxStyle', 'outline', ...    % Outline only, no fill
        'PlotStyle', 'traditional');  % Traditional style

    % Find box objects
    h = findobj(gca, 'Tag', 'Box');

    % Set no fill and increase outline thickness
    for j = 1:length(h)
        % Make outline thicker
        set(h(j), 'LineWidth', 2);

        % Ensure no fill (remove patch filling)
        patch(get(h(j), 'XData'), get(h(j), 'YData'), 'w', ...
            'FaceColor', 'none', 'EdgeColor', get(h(j), 'Color'), 'LineWidth', 2);
    end
    mean(mean_temp2',1)
    
    mean_tempall1 = mean(mean_temp2,2);
    % x1 = 1:3;
    plot(x1,mean_temp2,'LineWidth',1,'Color',[0.8 0.8 0.8]);
    % plot(x1,mean_tempall1,'LineWidth',3,'Color',[0 0 0]);
    set(gca,'xlim',[0.75 3.25],'FontSize',28);
    box off;
    xticks([1 2 3])
    xticklabels('')
    ylabel('AUC')

    if ki ==3% plot only if first panel which is now Zi group 23rd sep 2025
        % ylabel('AUC')
        % ylabel('PeakVSD')
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.2, 0.54]);
        % set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.272, 0.52]);%auc
        % set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.272, 0.45]);
        xticklabels({'Saline', 'CNO','Recovery'})

    else
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.2, 0.5]);

        % set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.25,
        % 0.5]);% auc
        % set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.25, 0.45]);

    end
    hold off;
    % ylim([0 0.42])
    ylim([0 35])% for auc
    filename = sprintf(strcat('auc',num2str(ki,'%2d'),'.pdf'));
    fullpath = fullfile(outdir, filename);
    exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
    fprintf('Exported %s\n', fullpath);


end









