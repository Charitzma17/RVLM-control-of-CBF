% CODE to analyse ECG to calculate heart rate and R-R intervals
clc; clearvars; close all;
% load base_windowsForglucdreads.mat
% --------- User params ---------
Fs = 1000;                  % Hz (your sampling rate)
bp = [3 25];                % bandpass for ECG before peak finding

% hrlims 400-800 bpm
low= 60/400;
high = 60/800;
% --------- Load data ----------
filename = dir('*.adicht*'); 
data = adi.readFile();
hr_ch   = data.getChannelByName('Channel 1');
stim_ch   = data.getChannelByName('Channel 3');

num_trials = length(data.records);

% --------- Filter design -------
bpFilt = designfilt('bandpassiir', ...
    'FilterOrder', 8, ...
    'HalfPowerFrequency1', bp(1), ...
    'HalfPowerFrequency2', bp(2), ...
    'SampleRate', Fs);

% Collect metrics
all_rows = [];

for tr = 1:num_trials
    % ---- Get trial ----
    x_raw = hr_ch.getData(tr);
    stim_sig = stim_ch.getData(tr);
    if isempty(x_raw) || all(~isfinite(x_raw))
        warning('Trial %d has no valid data.', tr);
        continue;
    end

    % ---- Filter (zero-phase) ----
    x = filtfilt(bpFilt, x_raw);
    % xall(tr,:)= x;
    % ---- R-peak detection ----
    % Adaptive prominence from MAD; min RR  (≈500 bpm upper bound)
    prom = 1*median(abs(x - median(x)))
    minRR = high;
    peak_locs = findpeaks(x);
    locs = peak_locs.loc;
    min_peak_distance = round(minRR*Fs);
    min_peak_height = max(eps, prom);
    basewin = 10*Fs:50*Fs;%

    valid_pk_indices = x(locs)>min_peak_height;
    filtered_locs = locs(valid_pk_indices);
    filtered_locs1 = filtered_locs([true; diff(filtered_locs) > min_peak_distance]);
    time = [1:length(x_raw)]./Fs;
    % figure(2),
    % plot(time,x_raw,'Color',[0.8 0.8 0.8]),hold on;
    % plot(time,x,'k','LineWidth',2)
    % plot(filtered_locs1./Fs,x(filtered_locs1),'r*')
    % xlim([30 38])
    % xlabel('Time (s)')
    % ylabel('HR (V)');
    % set(gca,'FontSize',28);
    % set(gcf,'units','points','position',[0,0,1000,400])
    % hold off;
    % box off;

    % plot samp with signal
    figure(3),
    % plot(time-61,x_raw.*1000,'Color',[0.8 0.8 0.8]),hold on;
    plot(time-61,x.*1000,'Color',[0.6 0 0],'LineWidth',1.5); hold on;
    xline(0,'k-.','LineWidth',2)
    % plot(filtered_locs1./Fs,x(filtered_locs1),'r*')
    xlim([-2.5 2.5])
    ylim([-40 70])
    xlabel('Time (s)')
    ylabel('ECG (mV)');
    set(gca,'FontSize',24);
    set(gcf,'units','points','position',[0,0,700,350])
    hold off;
     outdir = 'E:\heartrate_analysiis_2025\data\chr_animal_nov15_2ndpostop';
    filename = sprintf('hrzoomed.pdf');
    fullpath = fullfile(outdir, filename);
    exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
    fprintf('Exported %s\n', fullpath);
    box off;
    figure(5);
    plot(time-61,stim_sig,'k','LineWidth',2); 
    xlim([-10 10])
    xlabel('Time from Stim Onset(s)')
    ylabel('Stim');
    set(gca,'FontSize',24);
    set(gcf,'units','points','position',[0,500,1200,200])
    hold off;
    % box off;
    % ---- RR intervals (seconds) + cleaning ----
    rr = diff(filtered_locs1)./Fs;
    % keep physiologically plausible mouse RR (≈100–500 bpm)
    rr = rr(rr > (high)) & rr < (low);




    

    %
    baseline_ep = x(basewin);
    N2 = length(baseline_ep);
    W2 = 0.5/Fs;%
    K2 = ceil(2*N2*W2-1)
    % K2 = Kall(1,ol);
    paramshr.fpass=[0.02 20]; % band of frequencies to be kept
    paramshr.Fs=Fs; % sampling frequency
    paramshr.tapers=[N2*W2 K2]; % taper parameters
    paramshr.pad=0; % pad factor for fft
    paramshr.err=[2 0.05];
    paramshr.trialave=0;
    [Shr,fhr,~]=mtspectrumc((baseline_ep-mean(baseline_ep))',paramshr);
    Shrall(tr,:)= Shr;
    % fhrall(tr,:) = fhr;
    % figure(4)
    % plot(fhr,log10(Shr),'LineWidth',2,'Color','r');
    % xlim(paramshr.fpass)
    % xlabel('Frequency (Hz)')
    % ylabel('LogSpectrum (HR)')
    % set(gca,'FontSize',28);
    % set(gcf,'units','points','position',[0,0,1000,600])
    % hold on;
    
% =================for chr_nov15data
    base_rr_win = 20*Fs:30*Fs;
    stim_rr_win = 60*Fs:65*Fs;
    post_rr_win = 66*Fs:76*Fs;

    %%================= for 12_22_2021
   %  base_rr_win = 40*Fs:50*Fs;
   %  stim_rr_win = 60*Fs:65*Fs;
   %  post_rr_win = 87*Fs:97*Fs;
   % if tr == 6 || tr ==7
   %  post_rr_win = 100*Fs:110*Fs;
   % end
% =======================for gluc_dreads_a1
 % base_rr_win = base_cleanwind(tr,1)*Fs:(base_cleanwind(tr,1)+10)*Fs;
 %    stim_rr_win = 60*Fs:65*Fs;
 %    post_rr_win = 66*Fs:76*Fs;
 % 
    base_x = x(base_rr_win);
    stim_x = x(stim_rr_win);
    post_x = x(post_rr_win);

    

    b_locs = findpeaks(base_x);
    blocs = b_locs.loc;
    valid_pk_indxb = base_x(blocs)>min_peak_height;
    filt_b_locs = blocs(valid_pk_indxb);
    filt_b_locs1 = filt_b_locs([true; diff(filt_b_locs) > min_peak_distance]);
 % ---- RR intervals (seconds) + cleaning ----
    rr_b = diff(filt_b_locs1)./Fs;
    % keep physiologically plausible mouse RR (≈100–500 bpm)
    % rr_b = rr_b(rr_b > (high)) & rr_b < (low);
    mean_rr(tr,1)= mean(rr_b);

    s_locs = findpeaks(stim_x);
    slocs = s_locs.loc;
    valid_pk_indxs = stim_x(slocs)>min_peak_height;
    filt_s_locs = slocs(valid_pk_indxs);
    filt_s_locs1 = filt_s_locs([true; diff(filt_s_locs) > min_peak_distance]);
    % ---- RR intervals (seconds) + cleaning ----
    rr_s = diff(filt_s_locs1)./Fs;
    % keep physiologically plausible mouse RR (≈100–500 bpm)
    % rr_s = rr_s(rr_s > (high)) & rr_s < (low);
    mean_rr(tr,2)= mean(rr_s);


    p_locs = findpeaks(post_x);
    plocs = p_locs.loc;
    valid_pk_indxp = post_x(plocs)>min_peak_height;
    filt_p_locs = plocs(valid_pk_indxp);
    filt_p_locs1 = filt_p_locs([true; diff(filt_p_locs) > min_peak_distance]);
    % ---- RR intervals (seconds) + cleaning ----
    rr_p = diff(filt_p_locs1)./Fs;
    % keep physiologically plausible mouse RR (≈100–500 bpm)
    % rr_p = rr_p(rr_p > (high)) & rr_p < (low);
    mean_rr(tr,3)= mean(rr_p);
    % figure(10)
    % 
    % subplot(311)
    % title(num2str(tr,'%2d'))
    % plot([1:length(base_x)]./Fs,base_x); hold on;
    % plot(filt_b_locs1./Fs,base_x(filt_b_locs1),'r*')
    % hold off;
    % subplot(312);
    % plot([1:length(stim_x)]./Fs,stim_x); hold on;
    % plot(filt_s_locs1./Fs,stim_x(filt_s_locs1),'r*')
    % hold off;
    % subplot(313);
    % plot([1:length(post_x)]./Fs,post_x);hold on;
    % plot(filt_p_locs1./Fs,post_x(filt_p_locs1),'r*')
    % hold off;
    pause
end

%% 

nomo = [8,10,12,17,21,24,27,28,29,32];% least motion 
list_hr = {'E:\heartrate_analysiis_2025\data\12_22_2021\';...
    'E:\heartrate_analysiis_2025\data\chr_animal_nov15_2ndpostop\';...
    'E:\heartrate_analysiis_2025\data\gluc_dread_a1_2022\'};

for k = 1:length(list_hr)
    strname = strcat(list_hr(k),'workspace');
    
    load(cell2mat(strname));
    size(mean_rr)
    if k == 1
        mean_rr_all = mean_rr;
    elseif k == 2
        mean_rr_all=[mean_rr_all;mean_rr];
    else
    mean_rr_all = [mean_rr_all;mean_rr(nomo,:)];
    end
end

% ====== Boxplot for rr interval ======
figure;
set(gcf, 'Position', [100, 100, 400, 350]); % Set figure size
bp1 =boxplot(mean_rr_all, 'Colors', [0.7 0 0], 'Labels', {'Pre', 'Stim', 'Post'});
set(gca, 'XColor', 'k', 'YColor', 'k', 'FontSize', 20);
ylabel('R-R interval');
box off;
hold on;
% exportgraphics(gcf, 'boxplot_CalciumPeaksPerMin.png', 'Resolution', 300);

% Fix box colors
h = findobj(gca, 'Tag', 'Box');
h = flipud(h);
for j = 1:length(h)
    patch(get(h(j), 'XData'), get(h(j), 'YData'), [0.7 0 0], 'FaceAlpha', 0.5);
end
hold off;
 % Make box edges black and thicker
      boxes = findobj(gca, 'Tag', 'Box');
      set(boxes, 'LineWidth', 2, 'Color', 'k'); % Black box edges

      % Fix whiskers - Make them black
      whiskers = findobj(gca, 'Tag', 'Whisker');
      set(whiskers, 'LineWidth', 2, 'Color', 'k'); % Black whiskers

      % Fix caps (horizontal lines at the ends of whiskers) - Make them black
      caps = findobj(gca, 'Tag', 'Cap');
      set(caps, 'LineWidth', 2, 'Color', 'k'); % Black caps

      % Fix median line - Make it black and thicker
      medians = findobj(gca, 'Tag', 'Median');
      set(medians, 'LineWidth', 2, 'Color', 'k'); % Black median line

      % Fix outliers - Change color to black
      outliers = findobj(gca, 'Tag', 'Outliers');
      delete(outliers)
      % Fix all line objects to ensure black whiskers and caps
      lines = findobj(gca, 'Type', 'Line'); % Find all line objects
      for i = 1:length(lines)
          set(lines(i), 'Color', 'k', 'LineWidth', 2); % Make all lines black
      end
ylim([0 0.2])
      % === Statistical tests for Calcium Peaks per Minute ===
      data = mean_rr_all; % [5 x 3] matrix: mice × conditions

      % Friedman test
      [p_friedman, tbl, stats] = friedman(data, 1, 'off');
      fprintf('\n[Calcium Peaks/min] Friedman p = %.4f\n', p_friedman);

      % Pairwise Wilcoxon signed-rank tests (non-parametric)
      [p12, ~] = signrank(data(:,1), data(:,2)); % Baseline vs Hypoxia
      [p13, ~] = signrank(data(:,1), data(:,3)); % Baseline vs Recovery
      [p23, ~] = signrank(data(:,2), data(:,3)); % Hypoxia vs Recovery

      fprintf('  Pre vs Stim: p = %.4f\n', p12);
      fprintf('  Pre vs Post: p = %.4f\n', p13);
      fprintf('  Stim vs Post: p = %.4f\n', p23);
      outdir = 'E:\heartrate_analysiis_2025';
      filename = sprintf('hrstats.pdf');
      fullpath = fullfile(outdir, filename);
      exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
      fprintf('Exported %s\n', fullpath);

%%
% Shrall: trials x freq
% fhr:    1 x freq or freq x 1 frequency vector (Hz)

% Ensure fhr is a row vector and matches Shrall's frequency dimension
fhr = fhr(:).';                      % make row
assert(size(Shrall,2) == numel(fhr), 'Shrall second dim must match numel(fhr)');

% Mean and SEM across trials (omit NaNs trial-wise)
mu  = mean(Shrall, 1, 'omitnan');
n   = sum(~isnan(Shrall), 1);        % number of non-NaN trials per freq bin
sem = std(Shrall, 0, 1, 'omitnan') ./ max(n,1).^.5;

% Plot shaded SEM
figure; hold on;
upper = mu + sem;
lower = mu - sem;

% Shaded area
xpoly = [fhr, fliplr(fhr)];
ypoly = [upper, fliplr(lower)];
hFill = fill(xpoly, ypoly, [0.6 0 0.6], 'EdgeColor', 'none', 'FaceAlpha', 0.25);

% Mean line
hMean = plot(fhr, mu, 'Color', [0.6 0 0.6], 'LineWidth', 2);

% Cosmetics
grid on; box off;
xlabel('Frequency (Hz)');
ylabel('Spectrum (HR)');
% title('Heart-rate Trial Spectra: Mean \pm SEM');
set(gca, 'FontSize', 14);
legend([hMean, hFill], {'Mean', 'SEM'}, 'Location', 'best');
xlim([min(fhr) max(fhr)]);
set(gcf, 'Position', [100, 100, 1200, 400]); % Set figure size
set(gca,'FontSize',24)

%%

% mean_rr_all: nTrials x 3 (columns = pre, stim, post)

% Create a table for repeated-measures ANOVA
T = table(mean_rr_all(:,1), mean_rr_all(:,2), mean_rr_all(:,3), ...
    'VariableNames', {'Pre','Stim','Post'});

% Define the within-subject factor
WithinDesign = table({'Pre';'Stim';'Post'}, 'VariableNames', {'Condition'});

% Fit repeated-measures model
rm = fitrm(T, 'Pre-Post~1', 'WithinDesign', WithinDesign);

% Run repeated-measures ANOVA
ranovatbl = ranova(rm);

% Display ANOVA table
disp(ranovatbl);

% Post-hoc pairwise comparisons
pairwise = multcompare(rm, 'Condition');

disp('Post-hoc pairwise comparisons:');
disp(pairwise);




