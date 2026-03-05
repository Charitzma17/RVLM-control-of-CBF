%%
clearvars
close all
clc


%
list= {'Y:\eeg_ldff_data\rvlm_stim_canula_ChR_animals\rvlm_chr_dreads_a3_postop27may2021\5secON_12mW_10kpersec_2V\all_tr.adicht';...
    'Y:\eeg_ldff_data\rvlm_stim_canula_ChR_animals\RVLM_Chr_Dreadds_a2_postoop11may2021\5secON_22mW_10kpersec_2V\all_tr.adicht';...
    'Y:\eeg_ldff_data\rvlm_stim_canula_ChR_animals\canula_ChR_a2_postop_29dec2020\5thfeb21\5secON_5sec_10kpersec\all_tr.adicht';};
% Define EEG bands with their frequency ranges
eeg_bands = struct( ...
    'Delta', [0.5, 4], ...
    'Theta', [4, 8], ...
    'Alpha', [8, 13], ...
    'Beta', [13, 30], ...
    'Gamma', [30, 59] ...
    );
% Initialize structure to store index ranges
index_ranges = struct();

% Loop through EEG bands to find index ranges
band_names = fieldnames(eeg_bands);
for l = 1:length(list)
    l
    % cd(list{l});
    % read channels
    data = adi.readFile(list{l});
    ecog_ch = data.getChannelByName('Channel 1');
    ldf_ch = data.getChannelByName('Channel 2');
    stim_ch = data.getChannelByName('Channel 3');

    num_trials = length(data.records);% num trials
    Fs =  10000; % 10k sampling rate
    tic;
    for tr = 1:num_trials
        num_trials
        ecog_tr = ecog_ch.getData(tr); %m x 1
        endpoint = length(ecog_tr);
        mean_ecog = mean(ecog_tr(1:endpoint));
        necog_tr = (ecog_tr(1:endpoint) - mean_ecog);% keeping it for the spectrogram

        sigma1 = 3000;
        windowSize1 = 50000;
        gaussianKernel1 = fspecial('gaussian', [windowSize1 1], sigma1);
        sm_ecog = conv(ecog_tr, gaussianKernel1, 'same');
        allecog_tr(l,tr,1:140*Fs) =sm_ecog(1:140*Fs);% save all
        base_ecog = mean(sm_ecog(5:55*Fs));% baseline
        mean_secog_base = mean(sm_ecog(1:58*Fs));% mean smooth baseline
        n_sm_ecog = (sm_ecog-mean_secog_base);% mean subtracted smooth ecog
        % std_necog_base = std(necog_tr(1:58*Fs));
        % thresh_ecog = mean_necog_base+std_necog_base;
        stim_ecog_tr = n_sm_ecog(60*Fs:65*Fs);% stim + 5sec
        % base_ecog_tr = sm_ecog(1:55*Fs);
        % post_ecog_tr = sm_ecog(66*Fs:120*Fs);

        nallecog_tr(l,tr,1:140*Fs) =n_sm_ecog(1:140*Fs);% save all
        ldf_tr = ldf_ch.getData(tr);
        sigma2 = 3000;
        windowSize2 = 50000;
        gaussianKernel2 = fspecial('gaussian', [windowSize2 1], sigma2);
        sm_ldf = conv(ldf_tr, gaussianKernel2, 'same');
        base_ldf = mean(sm_ldf(1:58*Fs));
        nldf_tr = (sm_ldf - base_ldf)./base_ldf;% normalize to baseline;


        preecog_for_cor = n_sm_ecog(40*Fs:60*Fs);
        preldf_for_cor = nldf_tr(40*Fs:60*Fs);
        stimecog_for_cor = n_sm_ecog(60*Fs:65*Fs);
        stimldf_for_cor = nldf_tr(60*Fs:65*Fs);
        postecog_for_cor1 = n_sm_ecog(70*Fs:90*Fs);
        postldf_for_cor1 = nldf_tr(70*Fs:90*Fs);
        postecog_for_cor2 = n_sm_ecog(120*Fs:140*Fs);
        postldf_for_cor2 = nldf_tr(120*Fs:140*Fs);

        n_allldf_tr(l,tr,1:140*Fs) =nldf_tr(1:140*Fs);% save all the ldfs for deconvolv later

        stim_ldf_tr = nldf_tr(60*Fs:65*Fs);% stim + 5sec
        baseldf_spec = nldf_tr(1:58*Fs);
        postldf_spec = nldf_tr(66*Fs:120*Fs);


        % pause

        %==========================spectrum pre and post=====%
        % N2 = length(baseldf_spec);
        % W2 = 0.02/Fs;%
        % K2 = ceil(2*N2*W2-1)
        % % K2 = Kall(1,ol);
        % paramsldfspec.fpass=[0 0.25]; % band of frequencies to be kept
        % paramsldfspec.Fs=Fs; % sampling frequency
        % paramsldfspec.tapers=[N2*W2 K2]; % taper parameters
        % paramsldfspec.pad=0; % pad factor for fft
        % paramsldfspec.err=[2 0.05];
        % paramsldfspec.trialave=0;
        % [Sldf_b,fldf_b,~]=mtspectrumc((baseldf_spec-mean(baseldf_spec))',paramsldfspec);
        % N2 = length(postldf_spec);
        % K2 = ceil(2*N2*W2-1)
        % paramsldfspec.tapers=[N2*W2 K2]; % taper parameters
        % [Sldf_p,fldf_p,~]=mtspectrumc((postldf_spec-mean(postldf_spec))',paramsldfspec);
        %
        % % Shrall(tr,:)= Shr;
        % % fhrall(tr,:) = fhr;
        % figure(5)
        % plot(fldf_b,Sldf_b,'LineWidth',2,'Color','g');
        %   hold on;
        % plot(fldf_p,Sldf_p,'LineWidth',2,'Color','b');
        % xlim(paramsldfspec.fpass)
        % xlabel('Frequency (Hz)')
        % ylabel('LogSpectrum (LDF)')
        % set(gca,'FontSize',28);
        % set(gcf,'units','points','position',[400,400,1000,600])
        %
        % idx_stim = find(stim_ldf_tr>thresh);
        % if (idx_stim)
        % stim_thrsh_ldf = stim_ldf_tr(idx_stim);
        peakstim_ldf = max(stim_ldf_tr(:));
        time_to_peak_ldf = find(stim_ldf_tr==peakstim_ldf);
        % idx_peak_ldf = find(stim_ldf_tr==peakstim);
        peakstim_ldf_tr(l,tr) = peakstim_ldf;% peak dilation
        aucstim_ldf_tr(l,tr) = trapz(stim_ldf_tr);% area under curve
        mean_ldf_tr(l,tr) = mean(stim_ldf_tr);% mean ldf
        top_ldf_tr(l,tr)= time_to_peak_ldf./Fs;% in seconds

        peakstim_ecog = max(stim_ecog_tr(:));
        time_to_peak_ecog = find(stim_ecog_tr==peakstim_ecog);
        top_ecog_tr(l,tr)= time_to_peak_ecog./Fs;% in seconds
        peakstim_ecog_tr(l,tr) = peakstim_ecog;

        figure(1),
        plot(-60+[1:length(ecog_tr)]./Fs,ecog_tr,'Color',[0.6 0.6 0.6]);
        hold on;
        plot(-60+[1:length(ecog_tr)]./Fs,sm_ecog,'b','LineWidth',2);
        xline(0,'k-.','LineWidth',3);
        xlim([-40 40])
        set(gcf,'units','points','position',[0,200,600,250])
        set(gca,'FontSize', 22);
        xlabel('Time (s)')
        ylabel('ECoG (\muV)');
        hold off;
        figure(2);
        plot(-60+[1:length(nldf_tr)]./Fs,nldf_tr,'LineWidth',2,'Color',[0.7 0 0]);
        xline(0,'k-.','LineWidth',3);
        xlim([-40 40])
        ylim([-0.2 0.3])
        set(gcf,'units','points','position',[0,400,600,250])
        set(gca,'FontSize', 22,'XTickLabel',[]);
        % xlabel('Time (s)')
        ylabel('\DeltaLDF/LDF');

        figure(3)
        hold on;
        plot(-60+[1:length(ecog_tr)]./Fs,n_sm_ecog,'Color',[0.8 0.8 0.8],'LineWidth',1);

        figure(5)
        hold on;
        plot(-60+[1:length(ecog_tr)]./Fs,nldf_tr,'Color',[0.8 0.8 0.8],'LineWidth',1);

        % pause
        %--spectrogram ldf
        % winSizeldf = 10;
        % win_overlapldf = 0.01;
        % winStepldf = winSizeldf*win_overlapldf; % step size in seconds for spectrogram in sec
        % windowldf = [winSizeldf winStepldf]; % moving window for spectrogram in sec
        % Wldf = 0.02; % this is W and must be equal to a small multiple (5) of the raleigh frequency 1/N
        % NWSpecgramldf = round(winSizeldf*Wldf); % time bandwidth product (i.e. T (total time)*dt (frequency resolution) = NW)
        % KSpecgramldf = 6;%ceil(2*NWSpecgramldf-1)            % Number of tapers (note - using floor instead of round
        % KSpecgram=10; % changed to 5 to make the analysis quicker
        %
        % if KSpecgramldf<1                                % can't have less that one taper! % more tapers will
        %     disp 'cannot resolve requested F'         % reduce the graininess of the spectrogram
        %     KSpecgramldf=1;
        % end
        %
        % paramsSpecgramLDF.tapers = [NWSpecgramldf 5];
        % paramsSpecgramLDF.pad = 1; % fft works by convolving a square. Padding adds more zeros to the end of the data to smooth the trace.  Doesn't make a whole lot of diff on outcome it seems
        % errorSig = 0.05;
        % paramsSpecgramLDF.err   = [2 errorSig]; % 0 = no error bars, [1,p] = theoretical error bar
        % s, [2,p] = jackknife error bars (95% CI)
        % paramsSpecgramECoG.trialave = 0;
        % timeStepECoG = YTime(2) - YTime(1);
        % paramsSpecgramLDF.Fs = Fs;%1 / timeStepECoG;             % aquisition frequency (Hz)
        % paramsSpecgramLDF.fpass = [0.05 0.4]; % [0 params.Fs/2]
        % SPECTRO.paramsSpecgramLDF=paramsSpecgramECoG;
        % [Sldf1,t2,fldf1,Serr1]=mtspecgramc((nldf_tr),windowldf,paramsSpecgramLDF);
        %
        %
        %
        % S__ldfdata{l,tr}.S = Sldf1;
        % S_ldfdata{l,tr}.f = fldf1;
        % S_ldfdata{l,tr}.t = t2;
        %
        %
        % figure(4);
        % imagesc(t2-60,fldf1,Sldf1'); axis xy; colorbar
        % colormap jet
        % xlabel('Time (s)')
        % ylabel('Frequency (Hz)')
        % title('LDF Power spectrum')
        % set(gca,'FontSize', 28);
        % set(gcf,'units','points','position',[200,400,800,800])
        % xlim([-40 70])

        %--spectrogram ECog
        winSize = 5;
        win_overlap = 0.2;
        winStep = winSize*win_overlap; % step size in seconds for spectrogram in sec
        window = [winSize winStep]; % moving window for spectrogram in sec
        W = 1; % this is W and must be equal to a small multiple (5) of the raleigh frequency 1/N
        NWSpecgram = round(winSize*W); % time bandwidth product (i.e. T (total time)*dt (frequency resolution) = NW)
        KSpecgram = floor(2*NWSpecgram-1);            % Number of tapers (note - using floor instead of round
        % KSpecgram=10; % changed to 5 to make the analysis quicker

        if KSpecgram<1                                % can't have less that one taper! % more tapers will
            disp 'cannot resolve requested F'         % reduce the graininess of the spectrogram
            KSpecgram=1;
        end

        paramsSpecgramECoG.tapers = [NWSpecgram 5];
        paramsSpecgramECoG.pad = 1; % fft works by convolving a square. Padding adds more zeros to the end of the data to smooth the trace.  Doesn't make a whole lot of diff on outcome it seems
        errorSig = 0.05;
        paramsSpecgramECoG.err   = [2 errorSig]; % 0 = no error bars, [1,p] = theoretical error bar
        % s, [2,p] = jackknife error bars (95% CI)
        paramsSpecgramECoG.trialave = 0;
        % timeStepECoG = YTime(2) - YTime(1);
        paramsSpecgramECoG.Fs = Fs;%1 / timeStepECoG;             % aquisition frequency (Hz)
        paramsSpecgramECoG.fpass = [0.02 100]; % [0 params.Fs/2]
        SPECTRO.paramsSpecgramECoG=paramsSpecgramECoG;
        [SECoG1,t1,fECoG1,Serr2]=mtspecgramc((necog_tr),window,paramsSpecgramECoG);
        idx_avg = find(fECoG1>30 & fECoG1<70);
        S_band = mean(SECoG1(:,idx_avg),2);
        S_band_all(l,tr,1) = mean(S_band(1:58));
        S_band_all(l,tr,2) = mean(S_band(60:70));
        S_band_all(l,tr,3) = mean(S_band(70:120));



        S_data{l,tr}.S = SECoG1;
        S_data{l,tr}.f = fECoG1;
        S_data{l,tr}.t = t1;


        figure(4);
        imagesc(t1-60,fECoG1,log10(SECoG1)'); axis xy; colorbar
        colormap jet
        xlabel('Time (s)')
        ylabel('Frequency (Hz)')
        % title('ECoG Power spectrum')
        set(gca,'FontSize', 20);
        set(gcf,'units','points','position',[900,100,300,450])
        xlim([-40 40])
        hold on;
        xline(0,'k-.','LineWidth',1.5);
        xline(5,'k-.','LineWidth',1.5);

        hold off;

        for i = 1:length(band_names)
            band = band_names{i};
            range = eeg_bands.(band);

            % Find indices for the lower and upper frequency limits
            idx_low = find(fECoG1 >= range(1), 1, 'first');
            idx_high = find(fECoG1 <= range(2), 1, 'last');

            % Store indexranges
            index_ranges.(band) = [idx_low, idx_high];
            Smeanband(:,i) = mean(SECoG1(1:140,idx_low:idx_high),2);
            bins = 1; %secz
            for tiempo = 1:bins:140-bins
                Avgband(l,tr,i,ceil(tiempo/bins)) = mean(Smeanband(tiempo:tiempo+bins,i));% band for 10 seconds epoch
            end
            % figure(tr); subplot(133);plot(Smeanband(:,i)); hold on;

        end
        S_data{l,tr}.bands = Smeanband;


        hold off;
        % pause
        % Ask once whether to export
        % choice = input('Enter 1 to export figures 1–4: ');
        % if choice == 1
        %     outdir = 'X:\kchhabria\eeg_ldff_data\sep15_2025_biphassic_data';
        %
        %     for f = 1:4
        %         if isvalid(figure(f))
        %             figure(f);
        %             filename = sprintf('Animal%d_Trial%d_Fig%d.pdf', l, tr, f);
        %             fullpath = fullfile(outdir, filename);
        %             exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
        %             fprintf('Exported %s\n', fullpath);
        %         end
        %     end
        % else
        %     disp('No figures exported for this trial.');
        % end

    end
end
%%
% Dimensions
% S_Band_all(m, t, p)
% p = 1 → pre, 2 → post

S_mouse = squeeze(nanmean(S_band_all, 2));
% Result: [nMice × nTimePeriods]
% S_mouse(:,1) = mean pre-stim per mouse
% S_mouse(:,2) = mean post-stim per mouse

figure; hold on
plot(S_mouse', '-o', 'Color', [0.6 0.6 0.6])  % individual mice
plot(mean(S_mouse,1), '-ko', 'LineWidth', 2, 'MarkerFaceColor','k')
xticks([1 2])
xticklabels({'Pre','Post'})
ylabel('S-band power')
title('Mouse-averaged S-band')
pre  = S_mouse(:,1);
post = S_mouse(:,2);

diffs = post - pre;   % within-mouse change

[h_norm, p_norm] = lillietest(diffs);
alpha = 0.05;

if p_norm > alpha
    disp('Differences are approximately normal → using paired t-test');
    [h,p,ci,stats] = ttest(post, pre);
    test_used = 'paired t-test';
    test_stat = stats.tstat;
    df = stats.df;
else
    disp('Differences are non-normal → using Wilcoxon signed-rank test');
    [p,h,stats] = signrank(post, pre);
    test_used = 'Wilcoxon signed-rank';
    test_stat = stats.signedrank;
    df = NaN;
end

%% cross correlation plot...

mean_corr_pre = squeeze(mean(corrall_pre,2));% mean across trials
mean_corr_stim = squeeze(mean(corrall_stim,2));% mean across trials
mean_corr_post1 = squeeze(mean(corrall_post1));
mean_corr_post2 = squeeze(mean(corrall_post2));

mean_lags_pre = squeeze(mean(lags_allpre,2));
mean_lags_stim = squeeze(mean(lags_allstim,2));
mean_lags_post1 = squeeze(mean(lags_allpost1,2));
mean_lags_post2 = squeeze(mean(lags_allpost2,2));

mean_precor = mean(mean_corr_pre,1);
sem_precor = std(mean_corr_pre,1)./sqrt(3);
mean_lagspre = mean(mean_lags_pre);
x_fill1 = [mean_lagspre, fliplr(mean_lagspre)];
y_fill1 = [mean_precor + sem_precor, fliplr(mean_precor - sem_precor)];


mean_stimcor = mean(mean_corr_stim,1);
sem_stimcor = std(mean_corr_stim,1)./sqrt(3);
mean_lagsstim = mean(mean_lags_stim);
x_fill2 = [mean_lagsstim, fliplr(mean_lagsstim)];
y_fill2 = [mean_stimcor + sem_stimcor, fliplr(mean_stimcor - sem_stimcor)];

mean_postcor1 = mean(mean_corr_post1,1);
sem_postcor1 = std(mean_corr_post1,1)./sqrt(3);
mean_lagspost1 = mean(mean_lags_post1);
x_fill3 = [mean_lagspost1, fliplr(mean_lagspost1)];
y_fill3 = [mean_postcor1 + sem_postcor1, fliplr(mean_postcor1 - sem_postcor1)];


mean_postcor2 = mean(mean_corr_post2,1);
sem_postcor2 = std(mean_corr_post2,1)./sqrt(3);
mean_lagspost2 = mean(mean_lags_post2);
x_fill4 = [mean_lagspost2, fliplr(mean_lagspost2)];
y_fill4 = [mean_postcor2 + sem_postcor2, fliplr(mean_postcor2 - sem_postcor2)];

figure(8);
hold on;
fill(x_fill1, y_fill1, [0 0 1], 'EdgeColor', 'none', 'FaceAlpha', 0.05); % light blue fill
plot(mean_lagspre,mean_precor,'b','LineWidth',2)
% fill(x_fill2, y_fill2, [1 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.05); % light blue fill
% plot(mean_lagsstim,mean_stimcor,'r','LineWidth',2)
fill(x_fill3, y_fill3, [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.05); % light blue fill
plot(mean_lagspost1,mean_postcor1,'k','LineWidth',2)
fill(x_fill4, y_fill4, [0 0 1], 'EdgeColor', 'none', 'FaceAlpha', 0.05); % light blue fill
plot(mean_lagspost2,mean_postcor2,'Color',[0 0.8 0],'LineWidth',2)
xline(0,'k-.','LineWidth',2);
xlim([-10 10])
xlabel('Lags (s)')
ylabel('Correlation');
set(gca,'FontSize',18)
set(gcf,'units','points','position',[400,0,300,380])
% ylim([-0.2 0.3])
l = legend('','Pre','','Post(10s)','','Post(60s)')
l.Location = "northwest";
l.FontSize = 12;
% outdir = 'X:\kchhabria\eeg_ldff_data\sep15_2025_biphassic_data';
% filename = sprintf('avgcorr.pdf');
% fullpath = fullfile(outdir, filename);
% set(gcf,'Renderer','opengl')
% exportgraphics(gcf, fullpath, 'ContentType', 'image', 'Resolution', 300);

%%


% mean_tr_ecog1 = squeeze(mean(nallecog_tr,2));% avg tr
% mean_tr_ldf = squeeze(mean(n_allldf_tr,2));% avg tr
for l = 1:size(nallecog_tr,1)
    countr = 1;
    for k= 1:size(nallecog_tr,2)
        tempecog = squeeze(nallecog_tr(l,k,:));
        if (tempecog)
            allecog(countr,:)= tempecog;
            countr= countr+1;
        end

    end
    mean_tr_ecog(l,:)= mean(allecog);
end

for l = 1:size(n_allldf_tr,1)
    countr = 1;
    for k= 1:size(n_allldf_tr,2)
        templdf = squeeze(n_allldf_tr(l,k,:));
        if (templdf)
            allldf(countr,:)= templdf;
            countr= countr+1;
        end
    end
    mean_tr_ldf(l,:)= mean(allldf,1);
end
%%
prewindow= 65*Fs:67*Fs;
stimwindow = 60*Fs:65*Fs;
postwindow1 = 70*Fs:80*Fs;
postwindow2 = 80*Fs:100*Fs;
for p = 1:size(mean_tr_ldf,1)
    avgprestimecog = mean_tr_ecog(p,prewindow);
    avgprestimldf = mean_tr_ldf(p,prewindow);
    [xcorr_avgpre, lagavgpre] = xcorr(avgprestimecog, avgprestimldf, 'normalized');
    lag_avgpre = lagavgpre / Fs;

    % Find peak correlation and corresponding lag
    [maxavgCorrpre, idxMaxavgpre] = max(xcorr_avgpre);
    lagAtavgMaxpre = lag_avgpre(idxMaxavgpre);
    figure(100);
    hold on;
    plot(lag_avgpre, xcorr_avgpre, 'g', 'LineWidth', 2);
    xlabel('Lag (s)');
    ylabel('Cross-correlation');
    % title('ECoG–LDF Cross-correlation');
    xline(0, 'r--', 'LineWidth', 1.5);
    grid on; box off;
end
%% avg plots
mean_all_ecog = squeeze(mean(mean_tr_ecog));
mean_all_ldf = squeeze(mean(mean_tr_ldf));
sem_ecog = std(mean_tr_ecog,[],1)./sqrt(3);% across mice
sem_ldf = std(mean_tr_ldf,[],1)./sqrt(3);% across mice

time_vector = -60+(1:length(necog_tr(1:140*Fs)))./Fs;

% Coordinates for shaded area
x_fill1 = [time_vector, fliplr(time_vector)];
y_fill1 = [mean_all_ecog + sem_ecog, fliplr(mean_all_ecog - sem_ecog)];

x_fill2 = [time_vector, fliplr(time_vector)];
y_fill2 = [mean_all_ldf + sem_ldf, fliplr(mean_all_ldf - sem_ldf)];

%%
% figure(6);
% hold on;
% fill(x_fill1, y_fill1, [0 0 1], 'EdgeColor', 'none', 'FaceAlpha', 0.1); % light blue fill
% plot(time_vector,mean_all_ecog','b','LineWidth',2)
% xline(0,'k-.','LineWidth',4);
% % xline(5,'g--','LineWidth',4)
% xlabel('Time (s)')
% ylabel('\DeltaECoG (\muV)');
% xlim([-25 25])
% ylim([-4 4])
% set(gcf,'units','points','position',[400,0,400,300])
% set(gca,'FontSize', 24);
% box off;
% outdir = 'X:\kchhabria\eeg_ldff_data\sep15_2025_biphassic_data';
% filename = sprintf('allavg_ecog.pdf');
% fullpath = fullfile(outdir, filename);
% set(gcf,'Renderer','opengl')
% exportgraphics(gcf, fullpath, 'ContentType', 'image', 'Resolution', 300);
% % fprintf('Exported %s\n', fullpath);
%
% figure(7);
% hold on;
% fill(x_fill2, y_fill2, [1 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.2); % light blue fill
% plot(time_vector,mean_all_ldf','r','LineWidth',2)
% xline(0,'k-.','LineWidth',4);
% % xline(5,'g--','LineWidth',4)
% % xlabel('Time (s)')
% ylabel('\DeltaLDF/LDF');
% xlim([-25 25])
% ylim([-0.2 0.2])
% set(gcf,'units','points','position',[400,200,400,200])
% set(gca,'FontSize', 24,'XTickLabel',[]);
% box off;
% outdir = 'X:\kchhabria\eeg_ldff_data\sep15_2025_biphassic_data';
% filename = sprintf('allavg_ldf.pdf');
% fullpath = fullfile(outdir, filename);
% set(gcf,'Renderer','opengl')
% exportgraphics(gcf, fullpath, 'ContentType', 'image', 'Resolution', 300);
% fprintf('Exported %s\n', fullpath);
% plot together october 2025-- run the mean_tr ecog cal and fill cal before this
%%

figure(6);

hold on;
yyaxis left
fill(x_fill1, y_fill1, [0 0 1], 'EdgeColor', 'none', 'FaceAlpha', 0.4); % light blue fill
plot(time_vector,mean_all_ecog','b-','LineWidth',2)
xline(0,'k-.','LineWidth',4);
ylim([-2 4])
ylabel('\DeltaECoG (\muV)');

yyaxis right
fill(x_fill2, y_fill2, [1 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.4); % light blue fill
plot(time_vector,mean_all_ldf','r-','LineWidth',2)
xlabel('Time (s)')
ylabel('\DeltaLDF/LDF');
xlim([0 10])
ylim([-0.2 0.15])
set(gcf,'units','points','position',[400,200,300,300])
set(gca,'FontSize', 15);
box off;
% Transparent background
set(gcf, 'Color', 'none');      % figure background
set(gca, 'Color', 'none');      % axes background

% Keep tick marks but remove their numeric labels
set(gca, 'XTickLabel', [], 'YTickLabel', []);

% Remove axis titles (if any)
xlabel('');
ylabel('');

% Optional aesthetics
box off;                        % removes outer box, keeps ticks
set(gca, 'TickDir', 'out');     % makes ticks point outward (cleaner look)

%%

outdir = 'X:\kchhabria\eeg_ldff_data\sep15_2025_biphassic_data';
filename = sprintf('allbothecogavg_ldf.pdf');
fullpath = fullfile(outdir, filename);
set(gcf,'Renderer','opengl')
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);
%% time to peak for the averages

for p = 1:3
    avg_ldf_top = mean_tr_ldf(p,60*Fs:65*Fs);
    avg_ecog_top = mean_tr_ecog(p,60*Fs:65*Fs);
    max_ldf = max(avg_ldf_top);
    max_ecog = max(avg_ecog_top);

    topldf(p) = find(avg_ldf_top==max_ldf);
    topecog(p) = find(avg_ecog_top==max_ecog);
    subplot(121)
    plot(avg_ldf_top); hold on;
    xline(topldf(p));
    subplot(122)
    plot(avg_ecog_top); hold on;
    xline(topecog(p));
    % pause
end


%% ==== PEAK-STIM: Histogram (pdf) + Kernel Density ====
% Inputs expected in workspace:
%   peakstim_ldf_tr      : [num_animals x num_trials]
%   (optional) peakstim_ecog_tr : [num_animals x num_trials]

% Colors
c_ldf  = [1 0.15 0];   % red
c_ecog = [0 0.35 1];   % blue

% ---------- LDF ----------
ldf_peak = peakstim_ldf_tr;
ldf_peak(ldf_peak==0) = NaN;
x_ldf = ldf_peak(:); x_ldf = x_ldf(~isnan(x_ldf));

figure('Color','w'); hold on;
if isempty(x_ldf)
    text(0.5,0.5,'No nonzero Peak-stim LDF trials found.', 'Units','normalized', ...
        'HorizontalAlignment','center','FontSize',12);
    title('Peak-stim LDF: histogram + kernel density'); axis off;
else
    % Histogram normalized to PDF (Freedman–Diaconis binning)
    histogram(x_ldf, 'Normalization','pdf', 'BinWidth', 0.072, ...
        'EdgeColor','none', 'FaceColor', c_ldf, 'FaceAlpha', 0.5);

    % % Kernel density estimate (requires Stats & ML Toolbox)
    % [f_ldf, xi_ldf, bw_ldf] = ksdensity(x_ldf);
    % plot(xi_ldf, f_ldf, 'Color', c_ldf, 'LineWidth', 2);

    % Axes
    x_min = min(x_ldf); x_max = max(x_ldf);
    x_pad = 0.06*(x_max - x_min + eps);
    xlim([x_min - x_pad, x_max + x_pad]);
    xlabel('PeakLDF');
    ylabel('Density');
    set(gcf,'units','points','position',[600,400,300,600])
    set(gca,'FontSize', 28);
    grid on; box off;
    ylim([0 4.5])
    % outdir = 'X:\kchhabria\eeg_ldff_data\sep15_2025_biphassic_data';
    % filename = sprintf('kdeldf.pdf');
    % fullpath = fullfile(outdir, filename);
    % exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
    % fprintf('Exported %s\n', fullpath);
end

mean(x_ldf)

std(x_ldf)
%% Get the size of Avgband
[num_mice, num_trials, num_bands, num_bins] = size(Avgband);

% Reshape Avgband to combine mice and trials into one dimension
reshaped_data = reshape(Avgband, [], num_bands, num_bins);  % (mice*trials) x bands x bins
reshap_ldf = reshape(peakstim_ldf_tr,num_mice*num_trials,1);
reshap_ldf(all(reshap_ldf == 0, 2), :) = [];% remove zero rows...
reshap_ldftr = reshape(n_allldf_tr,[],size(n_allldf_tr,3));
reshap_ldftr(all(reshap_ldftr == 0, 2), :) = [];% remove zero rows...
% Identify non-empty bins (bins where at least one value is non-NaN and non-zero)
valid_bins = false(1, num_bins);
for bin = 1:num_bins
    if any(~isnan(reshaped_data(:, :, bin)), 'all') && any(reshaped_data(:, :, bin) ~= 0, 'all')
        valid_bins(bin) = true;
    end
end

% Filter only valid bins
filtered_bins = find(valid_bins);
num_valid_bins = length(filtered_bins);

t1nw = t1(1:end);
t1nw = t1nw(1:139)+2.5;% first time point is 2.5 which is the center time of the window chosen in this case that being 5 sec
stim_range = find(t1nw>60&t1nw<65);
base_range = find(t1nw>0&t1nw<50);
% Define colors for each band
colors = [0.8,0,0.8;...
    0,0,0.8;...
    0,0.8,0;...
    0.8,0.8,0;...
    0.8,0,0];  % MATLAB's 'lines' colormap (different colors for each band)
bandnames = {'\delta';'\theta';'\alpha';'\beta';'\gamma'};
% Loop through each ECoG band and plot separately
for band = 1:num_bands
    % figure(band);  % Create a new figure for each ECoG band
    % hold on;
    % box off;


    % Extract spectral power data for this band and valid bins
    band_data = squeeze(reshaped_data(:, band, filtered_bins));
    band_data(all(band_data == 0, 2), :) = [];% remove zero rows...

    % Compute mean and SEM
    band_mean = mean(log10(band_data), 1, 'omitnan');
    band_sem = std(log10(band_data), 0, 1, 'omitnan') ./ sqrt(size(band_data, 1));

    band_stim(:,band) = mean((band_data(:,stim_range)),2);
    band_base(:,band) = mean((band_data(:,base_range)),2);% ratiometric change in power..
    dpower_band(:,band) = (band_stim(:,band)-band_base(:,band))./(band_base(:,band));% norm power
    % Convert to cell array format for violinplot()214
    % violin_data = cell(1, num_valid_bins);
    % baseline_data = log10(mean(band_data(:,1:2),2));% taking the first two bins for the normalization...
    % for bin_idx = 1:num_valid_bins
    %     bin = filtered_bins(bin_idx);
    %     violin_data{bin_idx} = log10(band_data(:, bin_idx)); % Collect valid bin data
    %     % n_violin_data{bin_idx} = log10(band_data(:, bin_idx))-baseline_; % Collect valid bin data
    % end
    %
    % % Plot violin plots withs custom color
    % vp = violin(violin_data, filtered_bins.*1);
    %
    % % Apply color to violins
    % for i = 1:length(vp)
    %     vp(i).FaceColor = colors(band, :); % Assign unique color to each band
    %
    % end
    % ylim([-2 1.5])
    %
    % % Labels and title
    % xlabel('Binned Time');
    % ylabel(' Log_{10}Power^{ECoG}');
    % title(strcat(bandnames{band},'Band'));
    % % set(gcf,'units','points','position',[0,0,1000,400])
    % set (gca,'FontSize',28)
    % box off
    % legend off
    figure(100)
    % Plot line with error bars
    errorbar(t1nw, band_mean, band_sem, '-', ...
        'Color', colors(band, :), 'LineWidth', 4, 'CapSize', 10);
    hold on;
    % Plot markers at the mean values (after errorbar)
    plot(t1nw, band_mean, 'o-', ...
        'Color', colors(band, :), ...
        'MarkerFaceColor', colors(band, :), ...
        'MarkerEdgeColor', colors(band, :), ...
        'LineStyle', 'none', ...
        'MarkerSize', 10, ...
        'LineWidth', 2);

    set (gca,'FontSize',28)
    set(gcf,'units','points','position',[0,0,800,800])

    xlabel('Time (s)');
    ylabel('log Spectral Power');
    % title('ECoG Band Spectral Power Over Time');
    % ylim(ylims);
    grid on;
    % xlim([0 120])
    ylim([-2.1 0.2])
    legend('\delta','','\theta','','\alpha','','\beta','','\gamma','','Orientation','horizontal')
end
%

% Data dimensions:
% reshap_ldf  → 75 x 1
% band_stim   → 75 x 5

% Optional band names
band_names = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'};

% Colors for each band

% Loop over bands
for band = 1:5
    figure;
    scatter(reshap_ldf, dpower_band(:, band), 60, ...
        'MarkerFaceColor', colors(band, :), ...
        'MarkerEdgeColor', colors(band, :), ...
        'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);

    xlabel('LDF Signal');
    ylabel('Band Power');
    title(['LDF vs ' band_names{band}]);
    grid on;

    % Optional: add least-squares regression line
    hold on;
    % Fit a line
    coeffs = polyfit(reshap_ldf, dpower_band(:, band), 1);
    x_fit = linspace(min(reshap_ldf), max(reshap_ldf), 100);
    y_fit = polyval(coeffs, x_fit);
    plot(x_fit, y_fit, '--', 'Color', colors(band, :), 'LineWidth', 1.5);

    % Optional: display correlation
    R = corr(reshap_ldf, dpower_band(:, band), 'rows', 'complete');
    text(0.05, 0.9, sprintf('r = %.2f', R), ...
        'Units', 'normalized', ...
        'FontSize', 10, 'FontWeight', 'bold');
    set(gca,'FontSize',28);

    set(gcf,'units','points','position',[0,0,500,500])
    ylim([-1 1.5])

end

%% deconvolve the signals
% Resample LDF to match ECoG band power (assumed at 1 Hz)
% Settings
original_fs = 10000;       % Original LDF sampling rate
target_fs = 1;             % Target (same as ECoG band power)
max_lag = 10;              % Max lag in seconds (10 bins at 1 Hz)
% Total time points after resampling
num_trials = size(reshap_ldftr, 1);
num_bands = size(reshaped_data, 2);

% Define lag vector
lagpre = 0:max_lag;
for b = 1:num_bands
    band_data = squeeze(reshaped_data(:, b, filtered_bins));
    band_data(all(band_data == 0, 2), :) = [];% remove zero rows...
    band_matrix(:,b,:)= band_data;
end
stim_range = 45:75;
T = length(stim_range);
for k = 1:num_trials
    % --- Step 1: Preprocess LDF ---
    ldf_raw = reshap_ldftr(k,:)';                     % Full LDF trace
    ldf_filt = lowpass(ldf_raw, 0.4, original_fs);    % Filter before downsampling
    ldf_resampled = resample(ldf_filt, target_fs, original_fs);  % Resample to 1 Hz
    ldf_resampled = ldf_resampled(1:140);               % Trim to 140 points (if needed)
    ldf_taken = ldf_resampled(stim_range);
    % --- Step 2: Get ECoG band power for trial ---


    % --- Step 3: Build time-lagged design matrix X ---
    X = [];
    for b = 1:num_bands
        ecog_band = squeeze(band_matrix(k,b, stim_range));  % Convert to column vector (T x 1)

        % Build lagged matrix for this band (T x max_lag+1)
        X_band = zeros(T, max_lag+1);
        for lag = 0:max_lag
            temp = zeros(T, 1);
            temp(lag+1:end) = ecog_band(1:end-lag);
            X_band(:, lag+1) = temp;
        end
        X = [X, X_band];  % Concatenate band-wise
    end

    % --- Step 4: Trim beginning to remove lag padding ---
    X = X(max_lag+1:end, :);                  % Remove top rows with zeros
    ldf_trimmed = ldf_taken(max_lag+1:end);  % Align LDF accordingly

    % --- Step 5: Ridge Regression to estimate kernel ---
    lambda = 0.1;
    I = eye(size(X,2));
    h = (X' * X + lambda * I) \ (X' * ldf_trimmed);  % Ridge solution

    % --- Step 6: Reshape kernel output (lags × bands) ---
    kernels = reshape(h, max_lag+1, num_bands);
    kernels_alltr(k,:,:)= kernels;
    for bandnum = 1:num_bands
        h_band = kernels(:,bandnum);
        peak_wt(k,bandnum) = max(h_band);
        lag_pk(k,bandnum) = find(h_band==peak_wt(k,bandnum));
    end
    % --- Step 7: Plot kernels for this trial ---
    % figure('Name', ['Kernel: Trial ' num2str(k)], 'Color', 'w');
    % for b = 1:num_bands
    %     subplot(num_bands, 1, b);
    %     plot(lags, kernels(:, b), '-o', 'LineWidth', 2);
    %     xlabel('Lag (s)');
    %     ylabel('Kernel Weight');
    %     title(['Band ' num2str(b)]);
    %     grid on;
    % end
end
%% Assumes:

band_names = {'$\delta$', '$\theta$', '$\alpha$', '$\beta$', '$\gamma$'};

% 1. Boxplot for Peak Kernel Weights
figure;
boxplot(peak_wt, 'Labels', char(band_names), 'Colors', colors, 'Symbol', 'k+');
title('Peak Kernel Weight per Band');
ylabel('Peak Kernel Weight');
grid on;

% Re-color box edges
h = findobj(gca,'Tag','Box');
for j = 1:length(h)
    patch(get(h(j),'XData'), get(h(j),'YData'), colors(end-j+1,:), 'FaceAlpha', 0.5);
end
% Now manually set LaTeX-style tick labels
set(gca, 'XTickLabel', {'$\delta$', '$\theta$', '$\alpha$', '$\beta$', '$\gamma$'}, ...
    'TickLabelInterpreter', 'latex');
set(gca,'FontSize',28);
set(gcf,'units','points','position',[0,100,800,500])

% 2. Boxplot for Lag at Peak
figure;
boxplot(lag_pk, 'Labels', band_names, 'Colors', colors, 'Symbol', 'k+');
title('Lag at Peak per Band');
ylabel('Lag (s)');
grid on;

% Re-color box edges
h = findobj(gca,'Tag','Box');
for j = 1:length(h)
    patch(get(h(j),'XData'), get(h(j),'YData'), colors(end-j+1,:), 'FaceAlpha', 0.5);
end
% Now manually set LaTeX-style tick labels
set(gca, 'XTickLabel', {'$\delta$', '$\theta$', '$\alpha$', '$\beta$', '$\gamma$'}, ...
    'TickLabelInterpreter', 'latex');
set(gca,'FontSize',28);
set(gcf,'units','points','position',[0,100,800,500])

% 3. Plot average kernel with SEM (shaded)
lags_vec = 0:(lagpre-1);
figure; hold on;

for b = 1:bands
    % Extract all kernels for this band (trials x lags)
    k_mat = squeeze(kernels_alltr(:, :, b));

    % Mean and SEM across trials
    k_mean = mean(k_mat, 1, 'omitnan');
    k_sem = std(k_mat, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(k_mat), 1));

    % Shaded error bar
    fill([lags_vec fliplr(lags_vec)], ...
        [k_mean + k_sem, fliplr(k_mean - k_sem)], ...
        colors(b,:), 'FaceAlpha', 0.1, 'EdgeColor', 'none');

    % Mean line
    plot(lags_vec, k_mean, '-', 'Color', colors(b,:), 'LineWidth', 2);
end

xlabel('Lag (s)');
ylabel('Kernel Weight');
title('Average Kernel with SEM per Band');
legend('$\delta$', '$\theta$', '$\alpha$', '$\beta$', '$\gamma$', 'Location', 'bestoutside');
grid on;
set(gca,'FontSize',28);
set(gcf,'units','points','position',[0,100,800,400])
