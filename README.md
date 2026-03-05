# RVLM-control-of-CBF
This branch calculates breathing rate expressed as interbreath intervals from the far infrared temperature capture using FLIR campera.
1. After motion correction using Deeplabcut the code ReadingDLC_andThermalCSVfiles_forKarishma.m calculates mean temperature from the videos.
2. Next, the code breathing_analyser_july2025.m analyses the temperature profiles calculating inter breath intervals across windows of time.
3. The same code can be used to next calculate spectrogram of breathing using Chronux toolbod.
4. The file video_Stimtime_analysis is used to corroborate stim timing to the recorded stim data using LABCHART.
