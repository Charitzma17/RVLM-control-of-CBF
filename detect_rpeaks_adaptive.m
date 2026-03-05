function [locs, pks, params] = detect_rpeaks_adaptive(x_raw, Fs, varargin)
% R2023a-safe robust mouse R-peak detector with adaptive height+prominence
% and a Pan–Tompkins style fallback. Also auto-detects polarity.

% --- options ---
opt.bp            = [5 45];     % Hz: wider for crisp QRS
opt.bpm_range     = [300 900];  % plausible mouse HR range
opt.env_win_s     = 0.05;       % envelope smoothing (s)
opt.height_k      = 0.3;        % looser start: median(env)+k*MAD
opt.prom_k        = 0.3;        % prominence in z-units, ~MAD scale
opt.retry_factor  = 0.5;        % halve thresholds when retrying
opt.max_retries   = 3;          % attempts before fallback
opt.debug_plot    = false;      % set true to visualize picks

for k = 1:2:numel(varargin), opt.(varargin{k}) = varargin{k+1}; end

% --- filter (zero-phase) ---
bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
    'HalfPowerFrequency1',opt.bp(1),'HalfPowerFrequency2',opt.bp(2), ...
    'SampleRate',Fs);
xf = filtfilt(bpFilt, x_raw);

% --- pick polarity that yields sharper peaks ---
if kurtosis(xf) < kurtosis(-xf)
    xf = -xf; pol = -1;
else
    pol = +1;
end

% --- robust z-score ---
mad1 = mad(xf,1); if mad1==0, mad1=1e-6; end
x_z = (xf - median(xf)) / mad1;

% --- envelope stats for adaptive thresholds ---
env = abs(hilbert(x_z));
env = movmedian(env, max(1, round(opt.env_win_s*Fs)));
env_med = median(env);
env_mad = mad(env,1); if env_mad==0, env_mad=1e-6; end

height_try = env_med + opt.height_k*env_mad;   % MinPeakHeight (z-units)
prom_try   = opt.prom_k;                        % MinPeakProminence (z-units)

% --- min distance from bpm upper bound ---
minRR = 60/opt.bpm_range(2); % s
MinPeakDistance = round(0.8*minRR*Fs);

% --- attempt loop: relax height & prominence if too few peaks ---
locs = []; pks = [];

for attempt = 0:opt.max_retries
    peak_locs = findpeaks(x_z);
    locs_temp = peak_locs.loc;
    pks_z= x_z(locs_temp);

    valid_pk_indices = x_z(locs_temp)>height_try;
    locs_try = locs_temp(valid_pk_indices);
    locs_try = locs_try([true; diff(locs_try) > MinPeakDistance]);

 % RR plausibility cleanup
    if numel(locs_try) >= 2
        rr = diff(locs_try)/Fs;
        keep = rr > 60/opt.bpm_range(1) & rr < 60/opt.bpm_range(2);
        locs_try = locs_try([true; keep]);
        pks_z    = pks_z([true; keep]);
    end

    % expected minimum beats (very loose)
    dur_s = numel(x_raw)/Fs;
    expected_min = max(5, floor(0.6 * dur_s * mean(opt.bpm_range)/120));
    if numel(locs_try) >= expected_min || attempt == opt.max_retries
        locs = locs_try;
        pks  = xf(locs); % amplitudes on filtered/oriented signal
        break;
    else
        height_try = height_try * opt.retry_factor;
        prom_try   = prom_try   * opt.retry_factor;
    end
end

% --- fallback: Pan–Tompkins-like if still too few ---
if numel(locs) < 5
    % Differentiate, square, integrate
    dx  = [0; diff(xf)];
    y   = dx.^2;
    win = max(1, round(0.05*Fs)); % 50 ms moving integration
    y   = movmean(y, win);

    % Threshold on y (robust)
    th  = median(y) + 2*mad(y,1);
    [~, locs_pt] = findpeaks(y, 'MinPeakHeight', th, ...
                                'MinPeakDistance', MinPeakDistance);
    % map back to xf and clean RR
    if numel(locs_pt) >= 2
        rr = diff(locs_pt)/Fs;
        keep = rr > 60/opt.bpm_range(1) & rr < 60/opt.bpm_range(2);
        locs_pt = locs_pt([true; keep]);
    end
    if numel(locs_pt) > numel(locs)
        locs = locs_pt; pks = xf(locs);
    end
end

% --- optional debug plot ---
if opt.debug_plot
    t = (0:numel(xf)-1)/Fs;
    figure; tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
    nexttile; hold on;
    plot(t, xf, 'k-'); 
    if ~isempty(locs), plot(t(locs), xf(locs), 'ro'); end
    title(sprintf('Filtered ECG (pol=%+d) | %d peaks', pol, numel(locs)));
    xlabel('Time (s)'); ylabel('Amplitude'); box on;

    nexttile; hold on;
    plot(t, x_z, 'Color',[0.2 0.5 1]);
    yline(height_try, '--');
    if ~isempty(locs), stem(t(locs), x_z(locs), '.'); end
    title(sprintf('z-signal (height=%.3f, prom=%.3f)', height_try, prom_try));
    xlabel('Time (s)'); ylabel('z'); box on;
end

params = struct('bp', opt.bp, 'polarity', pol, 'mad1', mad1, ...
    'height_final', height_try, 'prom_final', prom_try, ...
    'MinPeakDistance', MinPeakDistance);
end