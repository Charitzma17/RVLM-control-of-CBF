# RVLM-control-of-CBF
Heart rate analysis codes. 
1. This branch contains main code: heart_rate_analysis_aug12_2025.m that reads data from a LABCHART file.
2. Next, the code applies a band pass filter to keep the heart rate between 400-800 bpm.
3. It next detect the peaks and keeps the peak times to calculate the R-R intervals.
4. For every trial, a dynamic r peaks plot can be calculated using detect_rpeaks_adaptive.m to observe changes in R-R interval with stimulation.
5. Lastly, mean r-r intervals are calculated using rr_cal_local for prestimulus, stimulus, and poststimulus time periods for statistical comparisons.
