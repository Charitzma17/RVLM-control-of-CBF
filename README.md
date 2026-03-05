# RVLM-control-of-CBF
Code here read the recorded ECoG signal and laser doppler flowmetry signal from labchart files. It does the following:
1. It first reads the signals, subtracts the mean and plot the signals with respect to the stimulation of 5 seconds.
2. It calculated power of ECoG signal using Chronux package:http://chronux.org/
3. It then calculates various parameters from both ECoG and LDF signal.
4. It calculates peak and time to peak from the LDF signal during the stimulus epoch.
5. It also calculates time to peak from the ECoG signal during the stimulus epoch.
6. Next, it plots box plots of time to peak comparison of LDF and ECoG signals.
