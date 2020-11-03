using Arrow
using AxisIndices
using DataFrames
using DrWatson

@quickactivate "NeuriViz"
function load_eeg_data()
    eeg_data =
        Arrow.Table("/home/src/Projects/neuriviz/data/exp_pro/sub-002/ses-01/eeg/sub-002_ses-01_task-gonogo_run-01_eeg.arrow")
    electrodes_data =
        Arrow.Table("data/exp_pro/sub-002/ses-01/eeg/sub-002_ses-01_task-gonogo_run-01_electrodes.arrow")
    event_data =
        Arrow.Table("data/exp_pro/sub-002/ses-01/eeg/sub-002_ses-01_task-gonogo_run-01_events.arrow")

    # Based on sampling frequency, it can be assumed that each time represents 1 ms
    times = 1:length(eeg_data[1])
    # Given in Delorme paper
    sampling_freq = 1000
    # Assumed based on Delorme paper
    nosedir = "+X"

    subject_data = NamedAxisArray(
        [NamedAxisArray(
            [NamedAxisArray(
                [
                    DataFrame(eeg_data),
                    DataFrame(electrodes_data),
                    DataFrame(event_data),
                    nosedir,
                    times,
                    sampling_freq,
                ],
                information = [
                    :data,
                    :electrodes,
                    :events,
                    :nosedir,
                    :times,
                    :sampling_freq
                ],
            )],
            session = [1],
        )],
        subject = [1],
    )
    return subject_data
end

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
                4. `response_time` was used
        6. `events.json` is useful for decoding of values. Should be used in association with `events.tsv` to drop columns in that `tsv`. Not super useful at the moment but maybe in the future.
        7. `eeg.fdt` contains all the EEG data associated with that particular session. Incredibly important
        8. `.set` file contains very useful information pertaining to the `fdt` dataset. Values that are of great importance would be:
                1. `event` which is itself a dictionary that has the useful values. These values are repeated in the `events.tsv` file and does not need to be exactly reconstructed.
                2. `chaninfo/nosedir` contains the direction of the nose
                3. `times` records the time related to each data point from the fdt file
                4. `reject` contains information on how Delorme et. al. applied their ICA alogorithm
                5. `srate` contains the sampling frequency

I like this idea a lot. Thanks for the analogy. My underlying file format is Arrow for where the majority of my data is coming from. My goal would be to merge everything in this format as an Arrow Table which would also handle the problem of big tables. As I want to keep each table separate from each other, the table should never get bigger than 8 million data points or so. I know for a fact some of the information from files 2, 3, and 5 won't match the time series.
Do you think using something like AxisArrays or AxisIndices may be a good idea to be able to access data like this:
table["instance 1"]["session 1"]["session info"]
To access recording session information that does not match a time series and also this:
table["instance 1"]["session 1"]["time series data"]
To get the time series data associated with that instance's session since these two data structures have different dims? Essentially, four data structures: one that handles all the instances, another which handles the sessions, another which encodes the session information, and a final one to hold the time series data?

        Data -> Julia Script -> Makes the Data Structures from the four file formats
                1. AxisArray, RecursiveArrayTools, or, most likely, AxisIndice are used to manage a "meta" data structure which governs each subject:
                        1. Subject name comes from the name of the data file being loaded
                        2. Number of sessions comes from the data set and is associated with that particular subject
                2. Once each session for a subject is created via 1, the next data structure contains data not linked to a time series but to the recording session. May be useful to make this via RecursiveArrayTools or AxisArray. This data is the following:
                       1. `electrodes.tsv` which contains information on electrodes. Should probably convert this to an Arrow file first. Could be a simple data frame.
                       2. `coordsystem.json` which contains information the type of coordsystem used for recording EEG data. Probably fine to stay as a dict.
                       3. `.set` which contains valuable information regarding the `fdt` data. Can keep as a dict.:
                               1. `chaninfo/nosedir`
                               2. `times`
                               3. `reject`
                               4. `srate`
                       4. `events.tsv` should first have some rows dropped that are not of use for processing. Then, converted to an arrow format. Should be a data frame. Drop the following:
                               1. `duration`
                               2. `sample`
                               3. `stim_file`
                               4. `HED`
                3. Final data structure would be for the `fdt` file:
                        1. Data Frame wrapped around Arrow Table

                Goal:
                        `subjects["subject 1"]["session 1"]["session info"]`
                        `subjects["subject 1"]["session 1"]["time series data"]`


=#
