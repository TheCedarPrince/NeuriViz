module NeuriViz


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

export fdt_parser

end
