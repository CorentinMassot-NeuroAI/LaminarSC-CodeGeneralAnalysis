# LaminarSC-CodeGeneralAnalysis
MATLAB code for general analysis and display of laminar data recorded in the Superior Colliculus. 

Created by Corentin Massot, last update 06/21/2019


Main display functions:

analysis_events: displays laminar trial-averaged data

analysis_events_trials: displays laminar trial-by-trial data


Data management:

Load_data_gandhilab: creates datalist a list of datafiles names sorted by dates (indicated in the name of the files).

get_dlist: allows the analysis of specific datafiles. The numbers correspond to the numbers attributed by load_data_gandhilab

display_datalist: displays the content of datalist


Specific functions: (the results of each function is saved in the datafile in data.offline)

compute_fr: compute firing rate form spiking data

compute_lfp

filter lfp signal

compute_tuning

compute tuning target


Selection of features in CSD for alignment across sessions

Compute_CSDfeature: displays signals and CSD and call findfeatures_CSD

findfeatures_CSD: performs an automatic estimation of the boundaries of the visual sink (1 top and 2 bottom sink) and the reversal pattern during the motoric epoch. Ask user if a manual selection is preferred if the automatic estimation is not satisfying. Display also on the console the corresponding channel number to the selected depth of the bottom sink.

update_data: updates the data structure with the CSD alignment information and save it to the original data.    

Reference: please cite paper:  Massot C., Jagadisan U.K. & Gandhi N.J., Sensorimotor transformation elicits systematic patterns of activity along the dorsoventral extent of the superior colliculus in the macaque monkey, (to appear in) Communications Biology, 2019.


