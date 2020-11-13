using DrWatson
@quickactivate

using Javis
using NeuriViz

function ground(args...)
    background("white")
    sethue("black")
end

demo = Video(500, 500)
frames = 2
Background(1:frames, ground)

function stereo_projection(x, y, z)
    proj_x = x / (1 - z)
    proj_y = y / (1 - z)
    return (proj_x, proj_y)
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


function eeg_array(video, electrodes, index_electrode, inscribed_electrode, buffer = 50)
    xᵢ, yᵢ, zᵢ = index_electrode.position

    head_r = video.height / 2 - buffer / 2
    correction = head_r * xᵢ

    disp_ratio = head_r / xᵢ
    head_r = head_r * abs(head_r / correction)

    xₙ, yₙ = inscribed_electrode.position .* disp_ratio
    inscribed_r = √(xₙ^2 + yₙ^2)

    head_outline = Object(1:frames, (args...) -> circle(O, head_r, :stroke))
    inscribed_outline = Object(1:frames, (args...) -> circle(O, inscribed_r, :stroke))

    for electrode in electrodes
        x, y, z = electrode.position .|> arr -> arr .* disp_ratio
        Object(1:frames, (args...) -> channel(Point(y, x), "white", "black", :fill, 10, electrode.label))
    end

end

eeg_array(demo, electrode_array, electrode_array[27], electrode_array[13])

Javis.render(demo, pathname = "", tempdirectory="/home/src/Projects/neuriviz/assets/renders/")
