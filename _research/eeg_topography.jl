using DrWatson
@quickactivate

using Arrow
using AxisIndices
using DataFrames
# using Javis
using NeuriViz

struct Electrode
    label::String
    position::Array
    data::SubArray
end

# electrode_locations = [
    # O,
    # Point(-70, 0),
    # Point(70, 0),
    # Point(-140, 0),
    # Point(140, 0),
    # Point(0, 70),
    # Point(-50, 70),
    # Point(50, 70),
    # Point(0, -70),
    # Point(-50, -70),
    # Point(50, -70),
    # Point(115, -80),
    # Point(-115, -80),
    # Point(115, 80),
    # Point(-115, 80),
    # Point(40, -135),
    # Point(-40, -135),
    # Point(-190, -10),
    # Point(190, -10),
    # Point(-40, 135),
    # Point(40, 135),
# ]

# electrode_names = [
    # "Cz",
    # "C3",
    # "C4",
    # "T3",
    # "T4",
    # "Pz",
    # "P3",
    # "P4",
    # "Fz",
    # "F3",
    # "F4",
    # "F8",
    # "F7",
    # "T6",
    # "T5",
    # "Fp2",
    # "Fp1",
    # "A1",
    # "A2",
    # "O1",
    # "O2",
# ]

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
                    DataFrame(eeg_data, copycols=false),
                    DataFrame(electrodes_data, copycols=false),
                    DataFrame(event_data, copycols=false),
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
    )
    return subject_data
end

subject_data = load_eeg_data()

electrode_array = [
    Electrode(
        subject_data[subject = 1][session = 1][information = :electrodes][row, :].name,
        [
            subject_data[subject = 1][session = 1][information = :electrodes][row, :].x,
            subject_data[subject = 1][session = 1][information = :electrodes][row, :].y,
        ],
        @view subject_data[subject = 1][session = 1][information = :data][row]
    )
    for
    row = 1:size(subject_data[subject = 1][session = 1][information = :electrodes])[1]
]




