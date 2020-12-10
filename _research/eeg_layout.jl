using DrWatson
@quickactivate

using BenchmarkTools
using ColorSchemes
using Javis
using NeuriViz
using ScatteredInterpolation

function ground(args...)
    background("black")
end

function channel(
    p = O,
    fill_color = "white",
    outline_color = "black",
    action = :fill,
    radius = 25,
    circ_text = "",
)
    sethue(fill_color)
    circle(p, radius, :fill)
    sethue(outline_color)
    circle(p, radius, :stroke)
    text(circ_text, p, valign = :middle, halign = :center)
end

function tilemap(video, grid, radius, frame)
    circle(O, radius, :clip)
    rows, columns = size(grid)
    t = Tiler(video.width, video.height, rows, columns)

    for (pos, n) in t
        value = grid[t.currentrow, t.currentcol]
        setcolor(ColorSchemes.get(ColorSchemes.colorschemes[:gist_yarg], value))
        box(pos, t.tilewidth + 1, t.tileheight + 1, :fill)
    end

    sethue("black")
    Luxor.setline(2)
    clipreset()
    circle(O, radius, :stroke)
end

function eeg_array(video, electrodes, index_electrode, nosedir, buffer, frame_range)
    xᵢ, yᵢ, zᵢ = index_electrode.position
    head_r = video.height / 2 - (buffer + 10)
    disp_ratio = head_r / xᵢ

    shift_electrodes = []
    for electrode in electrodes
        x, y, z = electrode.position .|> arr -> arr .* disp_ratio
        shift_electrode = copy(electrode)
        shift_electrode.position[1] = x
        shift_electrode.position[2] = y
        shift_electrode.position[3] = z
        push!(shift_electrodes, shift_electrode)
    end

    for frame in frame_range
        Background(frame:frame, ground)
        topoplot_heatmap(video, Multiquadratic(), shift_electrodes, frame, head_r, nosedir)
	println(frame)
        # for electrode in shift_electrodes
        # x, y, z = electrode.position .|> arr -> arr .* disp_ratio
        # if nosedir == "+X"
        # p = Point(y, x)
        # else
        # p = Point(x, y)
        # end
        # Object(
        # frame:frame,
        # (args...) -> channel(p, "white", "black", :fill, 10, electrode.label),
        # )
        # end
    end

end

function topoplot_heatmap(video, interpolation_type, electrodes, frame, radius, nosedir)

    samples = Array{Float64}(undef, 0)
    grid = []
    pos_x = []
    pos_y = []

    #=
    #
    # These corrections are necessary as in default Julia matrices, one cannot
    # treat them completely like a Cartesian grid. Therefore, we need to ensure
    # each value will be positive shifted so that each value will be positive.
    #
    =#
    corr_x = trunc(video.width / 2)
    corr_y = trunc(video.height / 2)

    for electrode in electrodes
        push!(pos_x, round(electrode.position[1] + corr_x))
        push!(pos_y, round(electrode.position[2] + corr_y))
        push!(samples, electrode.data[1])
    end

    points = hcat(pos_x, pos_y)'
    interpolator = interpolate(interpolation_type, points, samples)

    for x = 1:(video.width)
        for y = 1:(video.height)
            evaluate(interpolator, [x, y]) |> value -> push!(grid, value)
        end
    end

    grid = reduce(hcat, grid) |> values -> reshape(values, video.width, video.height)

    if nosedir == "+X"
        grid = grid |> transpose
    end
    grid = grid .- minimum(grid) |> x -> x ./ maximum(x)
    Object(frame:frame, (args...) -> tilemap(video, grid, radius, frame))
end

include("eeg_topography.jl");

eeg_data_path = "/home/src/Projects/neuriviz/data/exp_pro/sub-002/ses-01/eeg/sub-002_ses-01_task-gonogo_run-01_eeg.arrow"
electrodes_data_path = "/home/src/Projects/neuriviz/data/exp_pro/sub-002/ses-01/eeg/sub-002_ses-01_task-gonogo_run-01_electrodes.arrow"
event_data_path = "/home/src/Projects/neuriviz/data/exp_pro/sub-002/ses-01/eeg/sub-002_ses-01_task-gonogo_run-01_events.arrow"

subject_data = load_eeg_data(eeg_data_path, electrodes_data_path, event_data_path);

electrode_array = [
    Electrode(
        subject_data[subject = 1][session = 1][information = :electrodes][row, :].name,
        [
            subject_data[subject = 1][session = 1][information = :electrodes][row, :].x,
            subject_data[subject = 1][session = 1][information = :electrodes][row, :].y,
            subject_data[subject = 1][session = 1][information = :electrodes][row, :].z,
        ],
        @view subject_data[subject = 1][session = 1][information = :data][row]
    )
    for
    row = 1:size(subject_data[subject = 1][session = 1][information = :electrodes])[1]
];

demo = Video(300, 300)

(@btime eeg_array(
    demo,
    electrode_array,
    electrode_array[27],
    subject_data[subject = 1][session = 1][information = :nosedir],
    0,
    1:250:length(electrode_array[1].data),
)) |> println

# @btime eeg_array(
    # $demo,
    # $electrode_array,
    # $electrode_array[27],
    # $subject_data[subject = 1][session = 1][information = :nosedir],
    # 0,
    # 1:length($electrode_array[1].data),
# )

Javis.render(demo, pathname = "test.gif", tempdirectory = "assets/renders/") 

