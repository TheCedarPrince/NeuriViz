using DrWatson
@quickactivate "NeuriViz"

#=

This script only works after installing the Delorme dataset.
It takes the raw dataset stored in `exp_raw` and processes it to the `exp_pro`.
Converts relevant data to `.arrow` file format.

=#

using Arrow
using CSV
using DataFrames
using MAT
using NeuriViz

# Get the files in a data directory
input_files = get_files(datadir("exp_raw"))

# Get particular files from a BIDS-structured dataset
electrode_files = filter_files(input_files, "electrodes.tsv")
event_files = filter_files(input_files, "events.tsv")
fdt_files = filter_files(input_files, ".fdt")
set_files = filter_files(input_files, ".set")

# Process raw dataset
for num = 1:length(fdt_files)

    # Get each file
    fdt_file = fdt_files[num]
    set_file = set_files[num]
    electrode_file = electrode_files[num]
    event_file = event_files[num]

    # Makes output directory for processed if path does not exist
    replace(dirname(fdt_file), "exp_raw" => "exp_pro") |> x -> !ispath(x) && mkpath(x)

    # Parses `fdt` data and converts it to `Arrow` file format
    dims = matread(set_file) |> mat -> Int.([mat["EEG"]["nbchan"], mat["EEG"]["pnts"]])
    data = fdt_parser(fdt_file, dims) |> transpose |> DataFrame
    Arrow.write(
        replace(fdt_file, ".fdt" => ".arrow") |> x -> replace(x, "exp_raw" => "exp_pro"),
        data,
    )

    # Parses `tsv` data and converts it to `Arrow` file format
    data = CSV.File(electrode_file) |> DataFrame!
    Arrow.write(
        replace(electrode_file, ".tsv" => ".arrow") |>
        x -> replace(x, "exp_raw" => "exp_pro"),
        data,
    )

    # Parses `tsv` data and converts it to Arrow file format
    data = CSV.File(event_file) |> DataFrame!
    Arrow.write(
        replace(event_file, ".tsv" => ".arrow") |> x -> replace(x, "exp_raw" => "exp_pro"),
        data,
    )

end

