module NeuriViz

using BIDSTools

"""

        fdt_parser(path::String, dims::Array{Int64, 1})

`fdt` files are a type of binary file format that stores "float data".
This function parses them to a Julia readable format provided the path to a `fdt` file and the dimensions of the output array.

# Arguments

- `path::String`: path to an `fdt` file
- `dims::Array{Int64, 1}`: array representing [rows, columns] of the desired output

# Returns

- `Array{Float32}`: Julia readable array containing parsed `fdt` data

"""
function fdt_parser(path, dims)
    parsed_data = open(path) do io
        read!(io, Array{Float32}(undef, (dims[1], dims[2])))
    end

    return parsed_data

end

function get_files(input_directory = "exp_raw", output_directory = "exp_pro")
    input_files = []
    output_files = []
    data_path = input_directory
    layout = Layout(data_path; load_metadata = false)
    for sub in layout.subjects
        for ses in sub.sessions
            output_path = output_directory * ses.path[(end - 14):end]
            input_path = data_path * ses.path[(end - 14):end]
            for file in ses.files
                input_file = input_path * file.path[(length(input_path) + 1):end]
                output_file = output_path * file.path[(length(input_path) + 1):end]
                push!(input_files, input_file)
                push!(output_files, output_file)
            end
        end
    end
    return input_files, output_files
end

filter_files(file_list, file_type) = filter(file_list -> occursin(file_type, file_list), file_list)

export fdt_parser, get_files, filter_files

end
