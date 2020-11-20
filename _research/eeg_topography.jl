using DrWatson
@quickactivate

using Arrow
using AxisIndices
using DataFrames
using NeuriViz

struct Electrode
    label::String
    position::Array
    data::SubArray
end

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
                    DataFrame(eeg_data, copycols = false),
                    DataFrame(electrodes_data, copycols = false),
                    DataFrame(event_data, copycols = false),
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
                    :sampling_freq,
                ],
            )],
            session = [1],
        )],
        subject = [1],
    );
    return subject_data
end

Base.copy(e::Electrode) = Electrode(e.label, Array{Float64, 1}(undef, 3), e.data)

export load_eeg_data 
