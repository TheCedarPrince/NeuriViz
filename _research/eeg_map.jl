using ImageFiltering
using Images
using Colors
using Luxor
using ColorTypes: ARGB32

function drawimagematrix(m)
    d = Drawing(500, 500, "/home/src/Projects/experiments/test.png")
    origin()
    circle(O, 170, :clip)
    w, h = size(m)
    t = Tiler(500, 500, w, h)
    mi = convertmatrixtocolors(m)
    for (pos, n) in t
        c = mi[t.currentrow, t.currentcol]
        setcolor(c)
        box(pos, t.tilewidth + 1, t.tileheight + 1, :fill)
    end
    sethue("black")
    setline(1)
    clipreset()
    circle(O, 170, :stroke)
    setline(2)
    radius = 15
    electrode_locations = [
        O,
        Point(-70, 0),
        Point(70, 0),
        Point(-140, 0),
        Point(140, 0),
        Point(0, 70),
        Point(-50, 70),
        Point(50, 70),
        Point(0, -70),
        Point(-50, -70),
        Point(50, -70),
        Point(115, -80),
        Point(-115, -80),
        Point(115, 80),
        Point(-115, 80),
        Point(40, -135),
        Point(-40, -135),
        Point(-190, -10),
        Point(190, -10),
        Point(-40, 135),
        Point(40, 135),
    ]

    electrode_names = [
        "Cz",
        "C3",
        "C4",
        "T3",
        "T4",
        "Pz",
        "P3",
        "P4",
        "Fz",
        "F3",
        "F4",
        "F8",
        "F7",
        "T6",
        "T5",
        "Fp2",
        "Fp1",
        "A1",
        "A2",
        "O1",
        "O2",
    ]
    electrode.(electrode_locations, "white", "black", :fill, radius, electrode_names)

    finish()
    return d
end

function convertmatrixtocolors(m)
    return convert.(Colors.RGBA, m)
end

function electrode(
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


test = @imagematrix begin
    background("white")
    t = Tiler(200, 200, 200, 200)
    for (pos, n) in t
        sethue(HSB(360 * noise(t.currentrow * 0.009, t.currentcol * 0.009), 1, 1))
        box(pos, 1, 1, :fillstroke)
    end
end 150 150

img = drawimagematrix(test)

#=

        Uncomment to demonstrate creating synthetic data.
        Can be an end point for actual EEG data in the future

=# 

# I = [ARGB32(1, 1, rand(), 1) for _ = 1:30, _ = 1:30]
# for val in 1:length(I)
    # if rand([true, false])
        # I[val] = ARGB32(1, 0, 1, 1)
    # end
# end

# img = imfilter(I, Kernel.gaussian(2))

# drawimagematrix(img)
