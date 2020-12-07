using DrWatson
@quickactivate

using Javis
using NeuriViz
using ScatteredInterpolation

function ground(args...)
    background("white")
    sethue("black")
end

demo = Video(500, 500)
frames = 1
Background(1:frames, ground)

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


function eeg_array(
    video,
    electrodes,
    index_electrode,
    nosedir,
    buffer = 50,
    inplace = false,
)
    xᵢ, yᵢ, zᵢ = index_electrode.position
    frames = 1

    head_r = video.height / 2 - buffer / 2
    correction = head_r * xᵢ

    disp_ratio = head_r / xᵢ
    head_r = head_r * abs(head_r / correction)

    head_outline = Object(1:frames, (args...) -> circle(O, head_r, :stroke))

    if inplace == false
        electrode_list = []
    end

    for electrode in electrodes
        x, y, z = electrode.position .|> arr -> arr .* disp_ratio
        if nosedir == "+X"
            p = Point(y, x)
        else
            p = Point(x, y)
        end
        Object(
            1:frames,
            (args...) -> channel(p, "white", "black", :fill, 10, electrode.label),
        )
        if inplace == true
            eletrode.position = [x, y, z]
        else
            shift_electrode = copy(electrode)
            shift_electrode.position[1] = x
            shift_electrode.position[2] = y
            shift_electrode.position[3] = z
            push!(electrode_list, shift_electrode)
        end
    end

    inplace == false && return electrode_list

end

function topoplot_heatmap(video, interpolation_type, electrodes, nosedir)

    pos_x = []
    pos_y = []
    samples = Array{Float64}(undef, 0)

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

    grid = []
    for x = 1:(video.width)
        for y = 1:(video.height)
            evaluate(interpolator, [x, y]) |> value -> push!(grid, value)
        end
    end

    grid = reduce(hcat, grid) |> values -> reshape(values, video.width, video.height)

    if nosedir == "+X"
        return rotl90(grid)
    else
        return grid
    end

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

shifted_electrodes = eeg_array(
    demo,
    electrode_array,
    electrode_array[27],
    subject_data[subject = 1][session = 1][information = :nosedir],
    50,
    false,
)

Javis.render(demo, pathname = "test.gif", tempdirectory = "assets/renders/")

hmap = topoplot_heatmap(
    demo,
    Multiquadratic(),
    shifted_electrodes,
    subject_data[subject = 1][session = 1][information = :nosedir],
)
