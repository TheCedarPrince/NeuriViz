using DrWatson
@quickactivate

using Arrow
using AxisIndices
using BIDSTools
using DataFrames
using NeuriViz

struct Electrode
    label::String
    position::Array
    data::SubArray
end

function load_eeg_data(data_path)

    layout = Layout(datadir(data_path); load_metadata = false)

    # TODO: Determine how to generalize adding relevant metadata to data

    # Based on sampling frequency, it can be assumed that each time represents 1 ms
    # times = 1:length(eeg_data[1])
    # Given in Delorme paper
    sampling_freq = 1000
    # Assumed based on Delorme paper
    nosedir = "+X"

    # TODO: Generalize loading of files at some point

    # NOTE: Use BIDSTools.get_files instead here
    for subject in layout.subjects
        for session in subject.sessions
            run_num = 1
            while BIDSTools.get_files(
                layout,
                sub = subject.identifier,
                ses = session.identifier,
                run = run_num |> num -> "0"^(2 - length(num)) * string(num),
            ) |> length != 0
                files = BIDSTools.get_files(
                    layout,
                    sub = subject.identifier,
                    ses = session.identifier,
                    run = run_num |> num -> "0"^(2 - length(num)) * string(num),
                )
                for file in files
                    if occursin("eeg.arrow", file.path)
                        eeg_data = Arrow.Table(file.path)
                    elseif occursin("events.arrow", file.path)
                        event_data = Arrow.Table(file.path)
                    else
                        electrodes_data = Arrow.Table(file.path)
                    end
                end

                subject_data = NamedAxisArray(
                    [NamedAxisArray(
                        [NamedAxisArray(
                            [NamedAxisArray(
                                [
                                    DataFrame(eeg_data, copycols = false),
                                    DataFrame(electrodes_data, copycols = false),
                                    DataFrame(event_data, copycols = false),
                                ],
                                run = [run_num],
                            )],
                            [nosedir, 1:length(eeg_data), sampling_freq],
                            metadata = [:nosedir, :times, :sampling_freq],
                        )],
                        session = [session.identifier |> id -> parse(Int, id)],
                    )],
                    subject = [subject.identifier |> id -> parse(Int, id)],
                )
            end
        end
    end
    return subject_data
end

# subject_data = load_eeg_data()

# electrode_array = [
# Electrode(
# subject_data[subject = 1][session = 1][information = :electrodes][row, :].name,
# [
# subject_data[subject = 1][session = 1][information = :electrodes][row, :].x,
# subject_data[subject = 1][session = 1][information = :electrodes][row, :].y,
# subject_data[subject = 1][session = 1][information = :electrodes][row, :].z,
# ],
# @view subject_data[subject = 1][session = 1][information = :data][row]
# )
# for
# row = 1:size(subject_data[subject = 1][session = 1][information = :electrodes])[1]
# ]


