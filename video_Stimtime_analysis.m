clearvars
close all
clc


% script for analysing video for stim time start
% start by reading the video files
% vid_location = 'C:\Users\kchhabria\Desktop\RVL_Stim_ThermalCam-Karishma-2024-02-06\videos';% data#1

% vid_location = 'C:\Users\kchhabria\Desktop\doubledreaddsm1_c1rvlmstim5sON-0011-KC-2025-07-18\videos';% data#2
% vid_location = 'C:\Users\kchhabria\Desktop\doubledreaddsf2-Kc-2025-07-16\videos';% data#3
vid_location = 'C:\Users\kchhabria\Desktop\doubledreaddsm2-KC-2025-07-20\videos';% data#4

cd (vid_location);
mp4File = dir(fullfile(vid_location, '*.mp4'));
vidObj = VideoReader(mp4File.name);
numFrames = floor(vidObj.Duration * vidObj.FrameRate);


% --- Read and display the first frame ---
firstFrame = readFrame(vidObj);
figure; imshow(firstFrame);
title('Draw a square over the LED region');
% --- Let user draw a square region ---
h = imrect;
position = round(wait(h));  % [x, y, width, height]

% --- Preallocate array to store average intensities ---
avgIntensity = zeros(numFrames, 1);

% --- Rewind video ---
vidObj.CurrentTime = 0;

% --- Process each frame ---
frameCount = 1;
while hasFrame(vidObj)
    frame = readFrame(vidObj);

    % Convert to grayscale if RGB
    if size(frame, 3) == 3
        frameGray = rgb2gray(frame);
    else
        frameGray = frame;
    end

    % Extract ROI and compute average intensity
    roi = imcrop(frameGray, position);
    avgIntensity(frameCount) = mean(roi(:));

    frameCount = frameCount + 1;
end

% --- Save results ---
save('led_avg_intensity.mat', 'avgIntensity');
plot(avgIntensity);
xlabel('Frame Number');
ylabel('Avg Intensity');
title('LED Intensity Over Time');

%%
fps = 30;
time = (0:length(avgIntensity)-1) / fps;  % time vector in seconds

avgSmoothed = movmean(avgIntensity, 200);  % Smooth over 5 frames

% --- Set a threshold for LED ON detection ---
threshold =  mean(avgSmoothed) + 2*std(avgSmoothed);  % or use mean + std, or manually defined

% --- Detect rising edges ---
isOn = avgSmoothed > threshold;
risingEdges = find(diff([0; isOn]) == 1);  % rising edges frame indices
% Filter based on minimum separation
minFramesApart = round(60 * fps);  % 30 seconds

filteredEdges = [];
lastEdge = -Inf;

for i = 1:length(risingEdges)
    if risingEdges(i) - lastEdge > minFramesApart
        filteredEdges(end+1) = risingEdges(i); %#ok<SAGROW>
        lastEdge = risingEdges(i);
    end
end 
% --- Create square stim signal ---
stimSignal = zeros(size(avgIntensity));
pulseDurationFrames = round(5 * fps);  % 5 seconds in frames

for i = 1:length(filteredEdges)
    startIdx = filteredEdges(i);
    endIdx = min(startIdx + pulseDurationFrames - 1, length(stimSignal));
    stimSignal(startIdx-18*30:endIdx-18*30) = 1;
end

% --- Plot results ---
figure;
plot(time, avgIntensity, 'b'); hold on;
plot(time, stimSignal * max(avgIntensity), 'r', 'LineWidth', 1.5);  % overlay
xlabel('Time (s)');
ylabel('Signal');
legend('Avg Intensity', 'Square Stim');
title('Detected LED ON Events');
