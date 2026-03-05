# RVLM-control-of-CBF
This branch has codes for HSV data analysis.
Cells counted manually are stored in .mat files
1. The hsv_analysis_mar_april2025.m reads the .mat files from different time points and all mice and pools them together for list of areas specified in the code.
2. Next, it calculates mean slope of cells across time points to determine the rate of viral spread or growth. Growth was linearly related to the pathlength calculated using code: pathlength_calculation_code_April2025.
3. From the slopes, it plots a cross correlation matrix showing clusters of areas showing similar growth patterns and hence higher probability of connection. Examples can be seen using the code cellprofile_plot_jan2026.m.
4. It then calculates a distance matrix, thresholded at r>0.7, and predicts a network from RVLM to the cortex using the code network_estimated_plot_April2025..
The network here is constrained using AAV based data of primary connections.
6. Next to assess candidate relays to cortex, all possible disynaptic pathways are chosen.
7. Next for all the primary nodes in the all possible disynaptic pathways, degree is calculated as a measure of centrality.
8. The code centrality.m calculated degree of the selected nodes based on the literature evidence of efferent and afferent projections provided in the supplementary table.
9. The nodes with 'high' centrality are chosen and validated on the criterion of known projection to cortex using existing literature.
