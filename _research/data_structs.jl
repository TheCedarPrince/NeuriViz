using Arrow 
using DrWatson 
using MAT 

@quickactivate "NeuriViz"

eeg_data = Arrow.Table("/home/src/Projects/neuriviz/data/exp_pro/sub-002/ses-01/eeg/sub-002_ses-01_task-gonogo_run-01_eeg.arrow")
