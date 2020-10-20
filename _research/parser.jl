using Arrow
using DataFrames
using DrWatson
using MAT

"""

`fdt` files are a type of binary file format that stores "float data".

"""
fdt_parser(path, mat) =
    open(path) do io
        read!(
            io,
            Array{Float32}(undef, (Int(mat["EEG"]["nbchan"]), Int(mat["EEG"]["pnts"]))),
        )
    end

# Reference: https://stackoverflow.com/questions/20484581/search-for-files-in-a-folder
searchdir(path, key) = filter(x -> occursin(key, x), readdir(path))

function fdt_to_arrow(file_path)

    subjects = searchdir(file_path, "sub")

    for sub_num in subjects
        sessions = readdir(file_path * "/" * sub_num)
        for ses_num in sessions
            eeg_sessions = readdir(file_path * "/" * sub_num * "/" * ses_num)
            for eeg_num in eeg_sessions
                files = searchdir(
                    file_path * "/" * sub_num * "/" * ses_num * "/" * eeg_num,
                    ".fdt",
                )
                headers = searchdir(
                    file_path * "/" * sub_num * "/" * ses_num * "/" * eeg_num,
                    ".set",
                )
                for (file, header) in zip(files, headers)
                    fdt_file =
                        file_path *
                        "/" *
                        sub_num *
                        "/" *
                        ses_num *
                        "/" *
                        eeg_num *
                        "/" *
                        file
                    header_file =
                        file_path *
                        "/" *
                        sub_num *
                        "/" *
                        ses_num *
                        "/" *
                        eeg_num *
                        "/" *
                        header
                    header_data = matread(header_file)
                    fdt_data = transpose(fdt_parser(fdt_file, header_data))
                    Arrow.write(
                        datadir(
                            "exp_pro",
                            "$sub_num",
                            "$ses_num",
                            "$eeg_num",
                            "$(file[1:end - 3])arrow",
                        ),
                        DataFrame(fdt_data),
                    )
                end
            end
        end
    end
end

@quickactivate "NeuriViz"

# fdt_to_arrow(datadir("exp_raw"))
