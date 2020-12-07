#=

Copyright 2020 Jacob Zelko (aka TheCedarPrince)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

using Luxor

function make_drawing(width, height, img_path, bkg_color, origin_p)
    d = Drawing(width, height, img_path)
    background(bkg_color)
    origin(Point(0, 0))
    return d
end

function iso_line(case_value, north, east, south, west)
    if case_value == 0 || case_value == 15
    elseif case_value == 1
        line(west, south, :stroke)
    elseif case_value == 2
        line(south, east, :stroke)
    elseif case_value == 3 || case_value == 12
        line(east, west, :stroke)
    elseif case_value == 4 || case_value == 11
        line(north, east, :stroke)
    elseif case_value == 5
        line(north, west, :stroke)
        line(south, east, :stroke)
    elseif case_value == 6 || case_value == 9
        line(north, south, :stroke)
    elseif case_value == 7 || case_value == 8
        line(north, west, :stroke)
    elseif case_value == 10
        line(north, east, :stroke)
        line(south, west, :stroke)
    elseif case_value == 13
        line(east, south, :stroke)
    elseif case_value == 14
        line(west, south, :stroke)
    end
end

iso_value(a, b, c, d) = a * 8 + b * 4 + c * 2 + d * 1

function create_grid(drawing, nrows, ncols)
    step_x = drawing.width / (ncols - 1)
    step_y = drawing.height / (nrows - 1)
    circ_scale = min(nrows, ncols) / max(nrows, ncols)
    points = Array{NamedTuple}(undef, nrows, ncols)
    for j = 1:nrows
        for i = 1:ncols
            cvalue = rand([0, 1])
            cvalue == 0 ? sethue("white") : sethue("black")
            pos = Point(step_x * (i - 1), step_y * (j - 1))
            circle(pos, 6 * circ_scale, :fill)
            points[j, i] = (x = pos.x, y = pos.y, val = cvalue)
        end
    end
    return points
end

function marching_squares(points)
    nrows, ncols = size(points)
    sethue("black")
    for j = 1:(nrows - 1)
        for i = 1:(ncols - 1)
            a = points[j, i]
            b = points[j, i + 1]
            c = points[j + 1, i + 1]
            d = points[j + 1, i]

            north = Point((b.x + a.x) / 2, a.y)
            east = Point(b.x, (b.y + c.y) / 2)
            south = Point((b.x + a.x) / 2, c.y)
            west = Point(a.x, (a.y + d.y) / 2)

            # circle(north, 2, :fill)
            # circle(east, 2, :fill)
            # circle(south, 2, :fill)
            # circle(west, 2, :fill)

            case = iso_value(a.val, b.val, c.val, d.val)

            # fontsize(14)
            # textcentered(string(case), Point((a.x + c.x) / 2, (a.y + c.y) / 2))

            iso_line(case, north, east, south, west)
        end
    end
end

width = 1200
height = 800

nrows = 25
ncols = 25

my_draw = make_drawing(
    width,
    height,
    "/home/src/Knowledgebase/Writings/thecedarprince.github.io/assets/squares_banner.png",
    "gray",
    Point(0, 0),
)
grid = create_grid(my_draw, nrows, ncols)

marching_squares(grid)
finish();
