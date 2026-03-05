# RVLM-control-of-CBF
The code here calculate vessel diameter as full width half width maximum of the imaged two photon imagges of pial vessels.
Two photon microscopy generates .tiffMap files that are read using custom tiffMap reader code that extracts the channels. 
The images are then processed serially using basic image processing set including thresholding, median filtering, contrast enhancement, and finally binarization.
The binarize images are then used to calculate full width half maximum. This is repeated for multiple trials.
