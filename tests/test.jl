using CSV
using DataFrames 

using Base.Filesystem: path_separator
using AWS: @service

@service S3
sync(bucket::AbstractString, dest::AbstractString) = _sync(bucket, dest, nothing)
function _sync(bucket, dest, token)
    params = Dict{String, String}()
    token === nothing || push!(params, "continuation-token" => token)
    resp = S3.list_objects_v2(bucket, params)
    for item in resp["Contents"]
        key = item["Key"]
        bytes = S3.get_object(bucket, key)
        path = joinpath(dest, replace(key, "/" => path_separator))
        mkpath(dirname(path))
        write(path, bytes)
    end
    if resp["IsTruncated"] == "true"
        _sync(bucket, dest, resp["NextContinuationToken"])
    end
end

sync("openneuro.org/ds002680", "download")

