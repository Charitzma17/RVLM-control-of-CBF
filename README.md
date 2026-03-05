# RVLM-control-of-CBF
This branch calculates parameters such as peak vasodilation and integrated vasodilation (area under the curve) of pial arterioles while blocking subthalamic or mibrain brainstem or both nuclei. 
1. Averaged traces and parameter calculation is coded in CNOdata_analysis_Jan2023.m that calculates for blocking ubthalamic or mibrain brainstem or both nuclei.
2. The code scatter_alldreads.m then plots the scatter plot showing the relative effect on decrease in peak and integrated vasodilation of all the inhibition experiments.
3. Average effect size of inhibition of subthalamic inhibition is calculated using AllSscalculation.m, of mibrain brainstem nuclei is calcualted using AllB_Mscalculation_September20_2025.m, and of both nuclei is calculated using AllS_B_Mscalculation.m.
4. Final prediction of effect size using either linear sum or pathlength weighted sum is calculated using Predicted_chemogenetic_response.m.
