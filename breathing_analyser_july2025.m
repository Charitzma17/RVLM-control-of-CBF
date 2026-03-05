clearvars
clc


file_dir = 'C:\Users\kchhabria\Desktop\RVL_Stim_ThermalCam-Karishma-2024-02-06\videos';
% file_dir ='C:\Users\kchhabria\Desktop\doubledreaddsm1_c1rvlmstim5sON-0011-KC-2025-07-18\videos';%

% file_dir = 'C:\Users\kchhabria\Desktop\doubledreaddsm2_reanalyse-KC-2025-07-23\videos';
% file_dir = 'C:\Users\kchhabria\Desktop\doubledreaddsf2_reanalyse-KC-2025-07-23\videos';

cd (file_dir)
load workspace

temp = thismeantemp(:,2);% this has the temp file

% load led_avg_intensity.mat

%%estimate fps for the video from the total time

% Fs = 147;
% T=(1:size(temp,1))./Fs;
% time_tot = T(end); % seconds
% 
% len_intensity = length(avgIntensity);% total number of frames or data points extracted from the video;
% f_est = len_intensity/time_tot;% this is the estimated frames per second of the exported video or recorded video ..
%% reading the labchart files for the estimate of the frames per second and start of camera recording
filename = dir('*.adicht*');
data = adi.readFile();
camtr_ch = data.getChannelByName('Channel 1');
stim_ch = data.getChannelByName('Channel 3');
% camtr_ch = data.getChannelByName('Channel 7');% only for f2 for  m1
% stim_ch = data.getChannelByName('Channel 1');% only for f2 for m1
Fs_labchart =  10000;
cam_sig = camtr_ch.getData(2);% 2nd record for lcdreadds
stim_sig = stim_ch.getData(2);
N = length(cam_sig); % Number of samples

total_time_sec = N / Fs_labchart;
fprintf('Total recording time: %.2f seconds\n', total_time_sec);
% Find rising edges
rising_edges = find(diff(cam_sig) > 3.5);

% Convert sample indices to time (in seconds)
frame_times = rising_edges / Fs_labchart;

% Compute frame intervals
frame_intervals = diff(frame_times);

% Average frame rate
frame_rate = 1 / mean(frame_intervals);
fprintf('Estimated frame rate: %.2f Hz\n', frame_rate);
camtr_start = frame_times(1);

%% addtional processing as the number of csv files are not the same as number of frames in the video...

num_frame_processed = length(temp);
expected_frames = length(frame_times);
fprintf('Expected frames:%0.2f ', expected_frames);
fprintf('Processed frames:%0.2f ', num_frame_processed);
timecut = num_frame_processed/frame_rate;
stim_cut = stim_sig(camtr_start*Fs_labchart:timecut*Fs_labchart);

%% lets plot both and see now....

figure(1)
ax1=subplot(211);
plot([1:length(temp)]./frame_rate,temp);
ax2=subplot(212)
plot([1:length(stim_cut)]./Fs_labchart,stim_cut);
linkaxes([ax1, ax2], 'x'); 

% %
% 
% avgSmoothed = movmean(avgIntensity, 500);  % Smooth over 5 frames
% 
% % --- Set a threshold for LED ON detection ---
% threshold =  mean(avgSmoothed) + 2*std(avgSmoothed);  % or use mean + std, or manually defined
% 
% % --- Detect rising edges ---
% isOn = avgSmoothed > threshold;
% risingEdges = find(diff([0; isOn]) == 1);  % rising edges frame indices
% % Filter based on minimum separation
% minFramesApart = round(60 * f_est);  % 30 seconds
% 
% filteredEdges = [];
% lastEdge = -Inf;
% 
% for i = 1:length(risingEdges)
%     if risingEdges(i) - lastEdge > minFramesApart
%         filteredEdges(end+1) = risingEdges(i); %#ok<SAGROW>
%         lastEdge = risingEdges(i);
%     end
% end 
% % --- Create square stim signal ---
% stimSignal = zeros(size(avgIntensity));
% pulseDurationFrames = round(5 * f_est);  % 5 seconds in frames
% 
% for i = 1:length(filteredEdges)
%     startIdx = filteredEdges(i);
%     endIdx = min(startIdx + pulseDurationFrames - 1, length(stimSignal));
%     stimSignal(startIdx-18*30:endIdx-18*30) = 1;
% end
% 
% % --- Plot results ---
% figure;
% plot(time, avgIntensity, 'b'); hold on;
% plot(time, stimSignal * max(avgIntensity), 'r', 'LineWidth', 1.5);  % overlay
% xlabel('Time (s)');
% ylabel('Signal');
% legend('Avg Intensity', 'Square Stim');
% title('Detected LED ON Events');
% 
% % filtering the signal for further frequency analysis
% 
% Fs = 333; % 333us is one frame duration

fc = 1;
order = 4;

% Design Butterworth high-pass filter
Wn = fc / (frame_rate/2); % Normalize the frequency
[b, a] = butter(order, Wn, 'high');

% Apply the filter
temp_filt = filtfilt(b, a, temp); % Zero-phase filtering to avoid phase shift

sigma1 = 70; % Standard deviation for Gaussian kernel
windowSize1 = 70; % Window size (should be large enough to avoid mean shift)
gaussianKernel = fspecial('gaussian', [windowSize1 1], sigma1);
sm_breath = conv(temp_filt, gaussianKernel, 'same');
figure, plot(temp_filt);
hold on;
plot(sm_breath,'LineWidth',4);
%% spectogram
winSize =5;
win_overlap = 0.08;%0.04;
winStep = winSize*win_overlap; % step size in seconds for spectrogram in sec
window = [winSize winStep]; % moving window for spectrogram in sec
W = 0.5;% in Hz
NWSpecgram = round(winSize*W); % time bandwidth product (i.e. T (total time)*dt (frequency resolution) = NW)
KSpecgram = ceil(2*NWSpecgram-1)

if KSpecgram<1                                % can't have less that one taper! % more tapers will
    disp 'cannot resolve requested F'         % reduce the graininess of the spectrogram
    KSpecgram=1;
end

paramsSpecgram.tapers = [NWSpecgram KSpecgram];
paramsSpecgram.pad = 1; % fft works by convolving a square. Padding adds more zeros to the end of the data to smooth the trace.  Doesn't make a whole lot of diff on outcome it seems
errorSig = 0.05;
paramsSpecgram.err   = [2 errorSig]; % 0 = no error bars, [1,p] = theoretical error bars, [2,p] = jackknife error bars (95% CI)
paramsSpecgram.trialave = 0;
% timeStepLFP = YTime(2) - YTime(1);
paramsSpecgram.Fs = frame_rate;%1 / timeStepLFP;             % aquisition frequency (Hz)
paramsSpecgram.fpass = [0 12]; % [0 params.Fs/2]
SPECTRO.paramsSpecgram=paramsSpecgram;
[Sbreath,t5,fbreath]=mtspecgramc(sm_breath-mean(sm_breath),window,paramsSpecgram);% spectrogram for whole signal

% subplot(211)
figure(5)
% Create a tight layout
t = tiledlayout(4,1,'TileSpacing','none','Padding','compact');

time = [1:length(stim_cut)]./Fs_labchart;
% Top panel: stim signal
nexttile(t,[1,1]);
plot(time, stim_cut, 'b', 'LineWidth', 3);  % overlay
xlim([t5(1) 500]);
box off;
set(gca, 'XTick', [], 'YTick', []);
% title('Stimulus');

nexttile(t,[3,1]);
imagesc(t5,fbreath,log10(Sbreath)'); axis xy;
hold on;
colorbar ('eastoutside');
xlim([t5(1) 500]);%     
% c.Limits = [0 1];
colormap jet
xlabel('Time (s)')
ylabel('Frequency (Hz)')
set(gca,'FontSize',16);
% title('Spectrogram of Breathing Signal');
set(gcf,'units','points','position',[0,0,500,250])
% saveas(gcf, 'ldfspectrogram_f1.tif');
outdir = 'E:\thermalcamera_breathingWArash\pictures_for_figure';
filename = sprintf('breathingspectrogramwpulses.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);

%%  

% Find stim onsets (rising edges)
stim_onsets = find(diff(stim_cut) > 4); % assuming square pulses go 0 to 6
stim_time = time(stim_onsets); % convert index to time in sec .. time is already in seconds....

% Pick first stim onset
trial_idx = 5;
trial_time = stim_time(trial_idx)*frame_rate;% converting from seconds to the frames for the signal ...

time_vid = 1:length(sm_breath);
% Extract time window
window = [-10 10].*frame_rate; % seconds before and after
mask = time_vid >= (trial_time + window(1)) & time_vid <= (trial_time + window(2));
t_window = time_vid(mask);% in frames
breath_window = sm_breath(mask);
raw_breath = temp_filt(mask);
% Plot
figure;
plot((t_window - trial_time)./frame_rate, raw_breath,'Color',[0.7 0.7 0.7],'LineWidth',2); % align to stim
hold on;
plot((t_window - trial_time)./frame_rate, breath_window,'Color',[0.6 0 0.6],'LineWidth',2); % align to stim

xline(0,'k-.','LineWidth',2)
xlabel('Time from Stim Onset (s)');
ylabel('Breathing Signal');
set(gca,'FontSize',20);
set(gcf,'units','points','position',[0,0,520,340])
box off;
% ---------------------
% INSET AXES
% ---------------------
% Get zoom window
zoom_mask = (t_window - trial_time)./frame_rate >= -2 & (t_window - trial_time)./frame_rate <= -1.53;
t_zoom = (t_window(zoom_mask) - trial_time) ./ frame_rate;
raw_zoom = raw_breath(zoom_mask);
sm_zoom = breath_window(zoom_mask);

% Create inset axes (position: [left bottom width height])
inset_pos = [0.82 0.75 0.08 0.2]; % adjust as needed
inset_ax = axes('Position', inset_pos);
plot(inset_ax, t_zoom, raw_zoom, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5);
hold(inset_ax, 'on');
plot(inset_ax, t_zoom, sm_zoom, 'Color', [0.6 0 0.6], 'LineWidth', 1.5);
xlim(inset_ax, [-2 -1.53]);
ylim(inset_ax, [-0.4 0.4])
% title(inset_ax, 'Single Breath');
set(inset_ax, 'FontSize', 14, 'Box', 'off');
% Optional: add rectangle in main plot to show zoomed region
rectangle('Position', [-2, min(raw_breath), 0.47, range(raw_breath)], ...
          'EdgeColor', [0.3 0.3 0.3], 'LineStyle', '--');
filename = sprintf('breathingexample.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);

%% Detect breathing peaks (spikes)
% Create a moving average filter (boxcar)
window_size = 20; % in samples (e.g. 100 samples = 0.1 sec if Fs=1000)
b = ones(1, window_size) / window_size;
a = 1;

sm_breath_smooth = filtfilt(b, a, sm_breath);% smoothing before peak detection for removing small jitters...

locs = findpeaks(sm_breath_smooth); % adjust if needed
peak_times = time_vid(locs.loc);% in frames
peak_values = sm_breath_smooth(peak_times);% peak_amplitudes..
% Filter peaks based on height
valid_peak_indices = find(peak_values>0.2);% 0.08 for all data except f2
filtered_locs = peak_times(valid_peak_indices);

% Ensure minimum separation between peaks (**s)
min_peak_distance = frame_rate.*0.1; % Convert **sec to samples
filtered_locs = filtered_locs([true, diff(filtered_locs) > min_peak_distance]);
figure;
plot(time_vid, sm_breath_smooth, 'Color','m', 'LineWidth',1.2); hold on;

plot(time_vid(peak_times), sm_breath_smooth(peak_times), 'ko', 'MarkerFaceColor', 'k');
xlabel('Time (s)');
%% ISI calcualtion and storage...
% Initialize matrix: rows = trials, cols = [pre, during, post]
nTrials = length(stim_time);
ISI_matrix = nan(nTrials, 3); % pre, stim, post

for i = 1:nTrials
    t_on = stim_time(i);
    t_off = t_on + 5; % stim is 5s

    % Pre-stim: -50 to 0s before stim
    pre_mask = peak_times >= (t_on - 50).*frame_rate & peak_times < t_on*frame_rate;
    pre_isis = diff(peak_times(pre_mask));
    pre_peak_amp = peak_values(pre_mask);
    pre_data = sm_breath_smooth((t_on - 50)*frame_rate: t_on*frame_rate);% actual data segregation...
    
    % Stim: 0 to 5s during stim
    stim_mask = peak_times >= t_on.*frame_rate & peak_times < t_off.*frame_rate;
    stim_isis = diff(peak_times(stim_mask));
    stim_peak_amp = peak_values(stim_mask);
    stim_data = sm_breath_smooth(t_on*frame_rate:  t_off*frame_rate);% actual data segregation...

    % Post-stim: 0 to 50s after stim
    post_mask = peak_times >= t_off.*frame_rate & peak_times < (t_off + 50).*frame_rate;
    post_isis = diff(peak_times(post_mask));
    post_peak_amp = peak_values(post_mask);
    post_data = sm_breath_smooth(t_off*frame_rate:  (t_off + 50)*frame_rate);% actual data segregation...

    figure(5);
    plot(pre_isis,'g');
    hold on;
    plot(stim_isis,'r');
    plot(post_isis,'b');
    % Store average ISIs
    ISI_matrix(i,1) = mean(pre_isis)./frame_rate;
    ISI_matrix(i,2) = mean(stim_isis)./frame_rate;
    ISI_matrix(i,3) = mean(post_isis)./frame_rate;

   % Store peak amplitude
   Peak_matrix(i,1) = mean(pre_peak_amp);
   Peak_matrix(i,2) = mean(stim_peak_amp);
   Peak_matrix(i,3) = mean(post_peak_amp);


   % calculate spectrum for pre stim and post for each trial
   N2 = length(pre_data)
   W2 = 1/frame_rate;%
   K2 = ceil(2*N2*W2-1)
   % K2 = Kall(1,ol);
   paramsbreath.fpass=[0.02 15]; % band of frequencies to be kept
   paramsbreath.Fs= frame_rate; % sampling frequency
   paramsbreath.tapers=[N2*W2 K2]; % taper parameters
   paramsbreath.pad=0; % pad factor for fft
   paramsbreath.err=[2 0.05];
   paramsbreath.trialave=0;
   [Spre,fpre,~]=mtspectrumc((pre_data-mean(pre_data))',paramsbreath);
   figure(10)
   plot(fpre,log10(Spre),'LineWidth',2,'Color','g');
   hold on;
   N2 = length(stim_data)
   W2 = 1/frame_rate;% keeping bw different for stim due to shorter epoch
   K2 = ceil(2*N2*W2-1)
   [Sstim,fstim,~]=mtspectrumc((stim_data-mean(stim_data))',paramsbreath);
   plot(fstim,log10(Sstim),'LineWidth',2,'Color','r');
   N2 = length(post_data)
   W2 = 1/frame_rate;% keeping bw different for stim due to shorter epoch
   K2 = ceil(2*N2*W2-1)
   [Spost,fpost,~]=mtspectrumc((post_data-mean(post_data))',paramsbreath);
   plot(fpost,log10(Spost),'LineWidth',2,'Color','b');
   hold off;
   Spec(i).pre = Spre;
   Spec(i).stim = Sstim;
   Spec(i).post = Spost;
% pause
end
%% post processing for stats
data_locs = {'C:\Users\kchhabria\Desktop\RVL_Stim_ThermalCam-Karishma-2024-02-06\videos\';...
    'C:\Users\kchhabria\Desktop\doubledreaddsm1_c1rvlmstim5sON-0011-KC-2025-07-18\videos\';...
    'C:\Users\kchhabria\Desktop\doubledreaddsm2_reanalyse-KC-2025-07-23\videos\';};
% Colors for 3 mice
mouse_colors = {[0.8 0.8 0.2], 'b', [0.5 0.5 0.5]}; % magenta, green, grey

% Labels for x-axis
cond_labels = {'Pre', 'Stim', 'Post'};

% Initialize for combined violin plots
ISI_all = [];    % ISI values
Peak_all = [];
group_ISI = [];  % Grouping var for x-axis
group_Peak = [];
mouse_ISI = [];  % Mouse ID for color coding
mouse_Peak = [];

for i = 1:length(data_locs)
   load(strcat(data_locs{i},'data_stats'));

    ISI = ISI_matrix;      % trials x 3
    Peak = Peak_matrix;    % trials x 3 


    % Condition group (1 = pre, 2 = stim, 3 = post)
    n_trials(i) = size(ISI,1);
    

    % Append
    ISI_all = [ISI_all; ISI];
    Peak_all = [Peak_all; Peak];
    
end

figure;
vp = violin(ISI_all, cond_labels);
hold on;
set(gca, 'XColor', 'k', 'YColor', 'k', 'FontSize', 14);
ylabel('ISI');
grid on;
legend off;
box off;
set(gcf,'units','points','position',[0,0,230,230])

for op = 1:3
    vp(op).FaceColor = [0.7, 0.2, 1];
end
% Overlay scatter
for i = 1:length(data_locs)

    if i ==1
        scatter(1:3,ISI_all(1:n_trials(i),:), 20 ,'k', 'filled', 'MarkerFaceAlpha', 1);
    else
        scatter(1:3,ISI_all(n_trials(i-1):n_trials(i),:),20, 'k', 'filled', 'MarkerFaceAlpha',1);
    end
end

xticks(1:3);
xticklabels(cond_labels);
grid off;
box off;
filename = sprintf('ISI.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);


figure;
vp1 = violin(Peak_all, cond_labels);
hold on;
set(gca, 'XColor', 'k', 'YColor', 'k', 'FontSize', 14);
for op = 1:3
    vp1(op).FaceColor = [1, 0.2, 0.7];
end
grid on;
legend off;
set(gcf,'units','points','position',[0,400,170,230])

% Overlay scatter
for i = 1:length(data_locs)
   if i ==1
        scatter(1:3,Peak_all(1:n_trials(i),:),20, 'k', 'filled', 'MarkerFaceAlpha', 1);
    else
        scatter(1:3,Peak_all(n_trials(i-1):n_trials(i),:),20, 'k', 'filled', 'MarkerFaceAlpha', 1);
    end
end

xticks(1:3);
xticklabels(cond_labels);
ylabel('Peak Amplitude');
box off;
grid off;
filename = sprintf('PeakAmp.pdf');
fullpath = fullfile(outdir, filename);
exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
fprintf('Exported %s\n', fullpath);

%% stats

% ISI_all: nTrials x 3 (pre, stim, post)
% Peak_all: same structure

datasets = {ISI_all, Peak_all};
names = {'ISI', 'Peak'};

for d = 1:numel(datasets)
    data = datasets{d};
    fprintf('\n===== Analyzing %s =====\n', names{d});
    
    % Step 1: Normality check
    numGroups = size(data,2);
    normality = false(1, numGroups);
    
    for g = 1:numGroups
        x = data(:,g);
        x = x(~isnan(x)); % remove NaNs
        [h,p] = lillietest(x);
        normality(g) = (h == 0);
        fprintf('Group %d: p=%.4f → %s normal\n', g, p, ternary(normality(g),'likely','not'));
    end
    
    % Step 2: Choose test
    if all(normality)
        % All normal → repeated measures ANOVA
        p_anova = anova1(data, [], 'off'); % one-way ANOVA
        test_used = 'Repeated-measures ANOVA (parametric)';
    else
        % At least one not normal → Friedman
        p_anova = friedman(data, 1, 'off');
        test_used = 'Friedman test (nonparametric)';
    end
    
    fprintf('Overall comparison using %s: p = %.4f\n', test_used, p_anova);

    % Step 3 (optional): post hoc
    if p_anova < 0.05
        fprintf('→ Significant overall difference, running post hoc tests...\n');
        if all(normality)
            % Pairwise t-tests with correction
            [~, p12] = ttest(data(:,1), data(:,2));
            [~, p23] = ttest(data(:,2), data(:,3));
            [~, p13] = ttest(data(:,1), data(:,3));
        else
            % Nonparametric pairwise tests
            p12 = signrank(data(:,1), data(:,2));
            p23 = signrank(data(:,2), data(:,3));
            p13 = signrank(data(:,1), data(:,3));
        end
        fprintf('Pre vs Stim: p=%.4f\nStim vs Post: p=%.4f\nPre vs Post: p=%.4f\n', ...
            p12, p23, p13);
    end
end

% --- Helper inline function ---
function out = ternary(cond, a, b)
    if cond, out = a; else, out = b; end
end
