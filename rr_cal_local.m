% CODE to calculate R-R intervals from the detected peak signal from the
% ECG data

clc; clearvars; close all;
% load base_windowsForglucdreads.mat
% --------- User params ---------
Fs = 1000;                  % Hz (your sampling rate)
bp = [3 25];                % bandpass for ECG before peak finding

% hrlims
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



 outdir = 'E:\heartrate_analysiis_2025\data\chr_animal_nov15_2ndpostop';
    
    % box off;
for tr = 1:num_trials
    % ---- Get trial ----
    x_raw = hr_ch.getData(tr);
    stim_sig = stim_ch.getData(tr);
    if isempty(x_raw) || all(~isfinite(x_raw))
        warning('Trial %d has no valid data.', tr);
        continue;
    end

    % --- Inputs ---
    % --- Inputs you already have/need ---
    % Fs        : sampling rate (Hz)
    % x_raw     : raw ECG (or similar) signal
    % bpFilt    : bandpass filter object for ECG
    % high, low : physiological RR bounds in seconds (e.g., high=0.12, low=0.6 for mice)
    %             NOTE: 'high' should be the MIN RR, 'low' the MAX RR.

    % --- User settings for overlapping bins ---
    win_s  = 5.0;    % window length in seconds (your "bin" size)
    step_s = 0.5;   % step between windows in seconds (e.g., 75% overlap)

    % --- Preprocess ---
    x  = filtfilt(bpFilt, x_raw);
    N  = numel(x);
    win = round(win_s  * Fs);
    hop = round(step_s * Fs);
    if win <= 1 || hop < 1
        error('win_s and step_s must be > 0.');
    end

    % --- Peak detection constraints (global distance; adaptive height per window) ---
    minRR            = high;                 % minimum RR (sec)
    min_peak_distance = max(1, round(minRR * Fs));

    % --- Prepare sliding windows ---
    nWins = floor((N - win)/hop) + 1;
    rr_win     = nan(1, nWins);             % avg RR (s) per window
    t_win_ctr  = nan(1, nWins);             % window center time (s)

    for w = 1:nWins
        idx_start = (w-1)*hop + 1;
        idx_end   = idx_start + win - 1;
        x_bin     = x(idx_start:idx_end);

        % Adaptive height from MAD inside window
        prom_bin        = median(abs(x_bin - median(x_bin)));
        min_peak_height = max(eps, prom_bin);   % avoid zero

        % Find peaks inside this window (local indices)
        [locs] = findpeaks(x_bin);
        locs_bin = locs.loc;
        valid_pk_indices_bin = x_bin(locs_bin)>min_peak_height;
        filtered_locs_bin = locs_bin(valid_pk_indices_bin);
        filtered_locs_bin1 = filtered_locs_bin([true; diff(filtered_locs_bin) > min_peak_distance]);
        % Compute RR inside this window (convert to seconds)
        if numel(filtered_locs_bin1) > 1
            rr_local = diff(filtered_locs_bin1) ./ Fs;
            % keep physiologically plausible RR only
            rr_local = rr_local(rr_local > high & rr_local < low);
            if ~isempty(rr_local)
                rr_win(w) = mean(rr_local, 'omitnan');
            end
        end

        % Window center time (s)
        t_win_ctr(w) = (idx_start + idx_end) / (2*Fs);
    end

    % --- OPTIONAL: interpolate short NaN gaps to keep continuity (comment out if undesired)
    rr_win = fillmissing(rr_win, 'linear');
    time = [1:length(x_raw)]./Fs;

    % --- Plot ---
    figure(4);
    plot(t_win_ctr-60, rr_win, 'LineWidth', 1,'Color',[1 0 0]);
    xlim([-30 30])
    ylim([0.10 0.15])
    xlabel('Time (s)');
    if tr ==1
        ylabel('R-R (s)');
    end
    set(gca,'FontSize',10);
    if tr ==1
            set(gcf,'units','points','position',[0,0,130,115])
    else
    set(gcf,'units','points','position',[0,0,70,110])
    end
    if tr>1
        set(gca, 'YTickLabel', []);
    end
    hold off;
    box off;
    filename = sprintf(strcat('rr_smooth_',num2str(tr,'%2d'),'.pdf'));
    fullpath = fullfile(outdir, filename);
    exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
    fprintf('Exported %s\n', fullpath);
    figure(5);
    plot(time-61,stim_sig,'k','LineWidth',1);
    xlim([-30 30])
    set(gca, 'XTickLabel', [], 'YTickLabel', []);
    % xlabel('Time from Stim Onset(s)')
    % ylabel('Stim');
    set(gca,'FontSize',10);
    set(gcf,'units','points','position',[0,500,70,30])
    hold off;
    box off;
    filename = sprintf('stim.pdf');
    fullpath = fullfile(outdir, filename);
    exportgraphics(gcf, fullpath, 'ContentType', 'vector', 'Resolution', 300);
    fprintf('Exported %s\n', fullpath);
    pause
end

