using Arrow 
using DrWatson 
using MAT 

@quickactivate "NeuriViz"

eeg_data = Arrow.Table("/home/src/Projects/neuriviz/data/exp_pro/sub-002/ses-01/eeg/sub-002_ses-01_task-gonogo_run-01_eeg.arrow")

#= 

        1. `channels.tsv` is not particularly useful
        2. `coordsystem.json` possibly useful to get EEG Coordinate System information and EEG Coordinate Units:
                1. `EEGCoordinateUnits`
                2. `EEGCoordinateSystem`
        3. `_eeg.json` is redundant based on the `set` file
        4. `electrodes.tsv` very useful and gives information on how many channels were used, their placement on the skull, and names of the electrodes. Data set up as follows:
                | name   | x    | y    | z    |
                | ------ | ---  | ---  | ---  |
                | FP1    | 0.83 | 0.27 | 0.48 |
        5. `events.tsv` is very useful for listing actual go/nogo events. Data set up as follows:
                | onset        | duration | sample | trial_type | response_time | stim_file  | value         | HED |
                | ---          | ---      | ---    | ---        | ---           | ---        | ---           | --- |
                | 5.0350000000 | n/a      | n/a    | stimulus   | 335           | 105064.jpg | animal_target | n/a |
                
                1. `onset` was used 
                2. `value` was used
                3. `trial_type` was used 
                4. `stim_file` was used 
                5. `response_time` was used 
                6. `HED` was used 
        6. `events.json` is useful for decoding of values. Should be used in association with `events.tsv` to drop columns in that `tsv`. Not super useful at the moment but maybe in the future. 
        7. `eeg.fdt` contains all the EEG data associated with that particular session. Incredibly important
        8. `.set` file contains very useful information pertaining to the `fdt` dataset. Values that are of great importance would be: 
                1. `event` which is itself a dictionary that has the useful values. These values are repeated in the `events.tsv` file and does not need to be exactly reconstructed.
                2. `chaninfo/nosedir` contains the direction of the nose
                3. `times` records the time related to each data point from the fdt file 
                4. `reject` contains information on how Delorme et. al. applied their ICA alogorithm
                5. `srate` contains the sampling frequency
                
=# 
