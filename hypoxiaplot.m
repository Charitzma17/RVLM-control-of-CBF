% CODE TO PROCESS FIBER PHOTOMETRY DATA.
% Data: Demultiplexed data for normalization and further processing for
clearvars
clc
close all

tic
micenames = {'f3','m1','f1','m1_2','bilatm1','bilatf1','bilatf2'};
%


nEpoch = 3;  % baseline, hypoxia, recovery

% Uncomment if doing multiple mice processing...
% nMice = 7;
% z_all   = cell(nMice, nEpoch);
% ldf_alldata = cell(nMice, nEpoch);

    load hypoxdata_S.mat;
    % equalize lengths
    % added on July 31st 2025 for the new patch cord data....
    if length(avg_415)~= length(avg_488)
        shortone = min([length(avg_415), length(avg_488)]);
        avg_415 = avg_415(1:shortone);
        avg_488 = avg_488(1:shortone);
    end
    p = polyfit(avg_415, avg_488, 1);           % Fit: avg_488 ≈ p(1)*avg_415 + p(2)
    fitted_415 = polyval(p, avg_415);           % Predicted baseline from control
    Fs_ldf = 20000;
    %Compute deltaF/F
    dF_F = (avg_488 - fitted_415) ./ fitted_415;
    tt1 = (1:length(ldf_sig))./Fs_ldf;
    Fs_adjust = floor(length(dF_F)/max(tt1));

    % resample and equalize the size of ldf and df/f for comparison
    ldf = ldf_sig;
    dwn_ldf = resample(ldf,Fs_adjust,Fs_ldf);

    whos_shrt = min([length(dF_F),length(dwn_ldf)]);
    dF_Fnew = dF_F(1:whos_shrt);
    dwn_ldf_new = dwn_ldf(1:whos_shrt);
    % Step 4: plot the two traces together and save as a figure
    tt2 = (1:length(dF_Fnew))./Fs_adjust;% coz may be sometime I wont highpass

    

    % read oxygen for hypoxia epochs

    filename_oxygen = 'oxygen_data.csv';
    data = readmatrix(filename_oxygen);

    % Extract columns
    time_ms = data(:, 1);           % Column 1: Timestamps in milliseconds
    oxygen_percent = data(:, 2);    % Column 2: O₂ concentration in %

    % Convert time to minutes
    time_min = time_ms / (1000 * 60);


    % Logical masks
    hypoxia_mask = oxygen_percent < 18;
    baseline_mask = oxygen_percent > 18;

    % --- Find Hypoxia Epoch ---
    hypoxia_start_idx = find(hypoxia_mask, 1, 'first');
    hypoxia_end_idx   = find(~hypoxia_mask(hypoxia_start_idx:end), 1, 'first') + hypoxia_start_idx - 2;


    if isempty(hypoxia_end_idx)
        hypoxia_end_idx = length(oxygen_percent); % If O₂ never recovers above 16%
    end

    % --- Find Baseline Epoch (before hypoxia) ---
    baseline_end_idx = hypoxia_start_idx - 1;
    % Go backward from baseline_end_idx and collect indices where O2 > 20%
    baseline_start_idx = 1;

    % --- Find Recovery Epoch (after hypoxia) ---
    recovery_start_idx = hypoxia_end_idx + 1;
    recovery_start_idx = recovery_start_idx + find(baseline_mask(recovery_start_idx:end), 1, 'first') - 1;

    recovery_end_idx = recovery_start_idx + find(~baseline_mask(recovery_start_idx:end), 1, 'first') - 2;
    if isempty(recovery_end_idx)% for those where i couldnt record all the oxygen till the end.. sensor issue
        recovery_end_idx = length(oxygen_percent);
    end
figure(1000);

        base_data_st_id = time_min(baseline_start_idx)+5% leave 10 min
        base_data_en_id = time_min(baseline_end_idx)
        hypox_data_st_id = time_min(hypoxia_start_idx)
        hypox_data_en_id = time_min(hypoxia_end_idx)
        recov_data_st_id = time_min(recovery_start_idx)
        recov_data_en_id = time_min(recovery_end_idx)-5

    
    
    
        basewin = floor(base_data_st_id)*60*Fs_adjust:floor(base_data_en_id)*60*Fs_adjust;% 5 min to 35 min
        hypoxwin = floor(hypox_data_st_id)*60*Fs_adjust:floor(hypox_data_en_id)*60*Fs_adjust;% 50 min to 70 min
        recovwin = floor(recov_data_st_id)*60*Fs_adjust:floor(recov_data_en_id)*60*Fs_adjust;% end-20 min: latest recovery
    
 % % --- Plotting the Epochs ---s
    figure(11);

    plot(time_min, oxygen_percent, 'k', 'LineWidth', 1.2); hold on;

    % Shade baseline
    area(time_min(baseline_start_idx:baseline_end_idx), ...
        oxygen_percent(baseline_start_idx:baseline_end_idx), ...
        'FaceColor', [0.6 0.9 0.6], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

    % Shade hypoxia
    area(time_min(hypoxia_start_idx:hypoxia_end_idx), ...
        oxygen_percent(hypoxia_start_idx:hypoxia_end_idx), ...
        'FaceColor', [1 0.6 0.6], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

    % Shade recovery
    area(time_min(recovery_start_idx:recovery_end_idx), ...
        oxygen_percent(recovery_start_idx:recovery_end_idx), ...
        'FaceColor', [0.6 0.6 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

    xlabel('Time (minutes)');
    ylabel('Oxygen Concentration (%)');
    title('Oxygen Sensor Readings with Epochs');
    legend('O₂ (%)', 'Baseline', 'Hypoxia', 'Recovery');
    % baseline mean subtraction
    mean_df_f = mean(dF_Fnew(basewin));
    norm_Fnew = (dF_Fnew-mean_df_f);
 
    meanldf = mean(dwn_ldf_new(basewin));
    norm_ldfnew = (dwn_ldf_new - meanldf);
    % plot raw signals
    figure(100); plot(avg_415); hold on; plot(avg_488)


    win_sec = 60;             

    % Smooth using Savitzky–Golay: polynomial order 3 is a good default
    poly_order = 3;
    dwn_ldf_sg = zp_sgolay(norm_ldfnew, Fs_adjust, win_sec, poly_order);
    dF_F_sg    = zp_sgolay(norm_Fnew,     Fs_adjust, win_sec, poly_order);
    t = (0:numel(dwn_ldf_new)-1)/Fs_adjust;

    figure(7),
    % subplot(212)
    % title (num2str(lp,'%2d'))

    hold on;
    % subplot(212)
    yyaxis left
    plot(tt2./60, dF_F_sg,'LineWidth',1,'Color',[0 0.7 0]);
    hold on;
    xlim([10 160])
    ylabel('dF/F(RVLM)','Color',[0 0.7 0])
    ax = gca;
    ax.YColor = [0 0.7 0];

    yyaxis right
    po = plot(tt2./60,dwn_ldf_sg,'LineWidth',2,'Color',[0.8 0 0]);
    po.Color(4) = 0.5;
    xline(hypox_data_st_id,'Color','k','LineWidth',4);
    xline(hypox_data_en_id,'Color','k','LineWidth',4);
    hold off;
    ylabel('Mean LDF')
    xlim([20 140])
    set(gca,'FontSize',28);
    xlabel('Time (min)');
    box off;
    set(gcf,'units','points','position',[0,0,2000,400])

    z_base = norm_Fnew(basewin);
    z_hypox = norm_Fnew(hypoxwin);
    z_recov = norm_Fnew(recovwin);

    ldf_base = norm_ldfnew(basewin);
    ldf_hypox = norm_ldfnew(hypoxwin);
    ldf_recov = norm_ldfnew(recovwin);

    filt_win = 1*60*Fs_adjust;
    medfilt_F = norm_Fnew-medfilt1(norm_Fnew,filt_win);
    medfilt_L = norm_ldfnew-medfilt1(norm_ldfnew,filt_win);

    z_base_c = medfilt_F(basewin);
    z_hypox_c = medfilt_F(hypoxwin);
    z_recov_c = medfilt_F(recovwin);

    ldf_base_c = medfilt_L(basewin);
    ldf_hypox_c = medfilt_L(hypoxwin);
    ldf_recov_c = medfilt_L(recovwin);


    [crossb, lagsb] = xcorr(z_base_c-mean(z_base_c),ldf_base_c-mean(ldf_base_c),'normalized');% cross correlation between subtracted means signals
    [crossh, lagsh] = xcorr(z_hypox_c-mean(z_hypox_c),ldf_hypox_c-mean(ldf_hypox_c),'normalized');% cross correlation between subtracted means signals
    [crossr, lagsr] = xcorr(z_recov_c-mean(z_recov_c),ldf_recov_c-mean(ldf_recov_c),'normalized');% cross correlation between subtracted means signals
    
    figure()
    hold on;
    plot(lagsb./(Fs_adjust),crossb,'LineWidth',2,'Color','g');
    plot(lagsh./(Fs_adjust),crossh,'LineWidth',2,'Color','m');
    plot(lagsr./(Fs_adjust),crossr,'LineWidth',2,'Color','b');
    xline(0,'r--')
    xlim([-50 50])
    set(gca,'FontSize',28);
    xlabel('Lags (s)')
    title('Cross Correlation cal--ldf')
    grid on;
    % pause
    toc
    

