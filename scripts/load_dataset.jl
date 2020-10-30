using DrWatson
@quickactivate "NeuriViz"

using NeuriViz

input_files, output_files = get_files(datadir("exp_raw"), datadir("exp_pro"))

fdt_output = filter_files(output_files, ".fdt") |> x -> replace.(x, ".fdt" => ".arrow")

fdt_input = filter_files(input_files, ".fdt")

set_files = filter_files(input_files, ".set")

electrode_files = filter_files(input_files, "electrodes.tsv")
