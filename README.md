# RVLM-control-of-CBF
Code to quantify the projections from AAV anterograde labelling from adrenergic cells in RVLM.
1. The mouse brains post morterm are imaged using Zeiss Axioscan and images of the sections are extracted as .tif files into folders using the Zen Blue software.
2. The images are processed using the projection_processingupdated_april2025.m using thresholding, contrast enhancement, binarization, and pixel quantification. These are done sequentially for different brains and data stored into cell format.
3. The data is then collected from the cells using aavanalysis_2025.m code to get the pixels intensities across all animals into arrays for plotting.
4. Next, the code newplotswarmdensity_sep19th_2025.m plot those pixel numbers into a swarm plot color coded for areas labelled caudorostrally.
