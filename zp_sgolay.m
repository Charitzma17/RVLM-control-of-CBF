%% ---------- Zero-phase Savitzky–Golay smoothing ----------
function y = zp_sgolay(x, Fs, win_sec, poly_order)
    % x: vector
    % win_sec: frame length in seconds (maps to odd number of samples)
    % poly_order: polynomial order (typical 2–4, must be < frameLen)
    x = x(:);

    frameLen = max(3, 2*ceil((win_sec*Fs)/2)+1);  % force odd length
    if nargin < 4 || isempty(poly_order), poly_order = 3; end
    if poly_order >= frameLen
        poly_order = frameLen - 1;
    end

    % Savitzky-Golay filter design
    [b,~] = sgolay(poly_order, frameLen);  % b is coeffs matrix

    % smoothing impulse response is the middle row
    h = b((frameLen+1)/2, :);

    % apply zero-phase filtering
    y = filtfilt(h, 1, x);

    if isrow(x), y = y.'; end
end
